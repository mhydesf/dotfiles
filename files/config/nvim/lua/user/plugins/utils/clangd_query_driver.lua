local M = {}

-- Return absolute path to compile_commands.json
local function find_ccjson(start_dir, compile_commands_dir)
  local uv = vim.uv or vim.loop
  local function join(a,b) return a .. '/' .. b end

  if compile_commands_dir then
    local p = join(start_dir, compile_commands_dir .. "/compile_commands.json")
    local st = uv.fs_stat(p)
    if st and st.type == "file" then return p end
  end

  -- walk up from project root
  local dir = start_dir
  while dir and dir ~= "" do
    local p = join(dir, "compile_commands.json")
    local st = uv.fs_stat(p)
    if st and st.type == "file" then return p end
    local parent = dir:match("^(.*)/[^/]+$")
    if parent == dir then break end
    dir = parent
  end
  return nil
end

local function read_file(p)
  local f = io.open(p, "rb")
  if not f then return nil end
  local s = f:read("*a"); f:close()
  return s
end

-- Extract the real compiler binary from a "command" string or "arguments" array
local function extract_driver_from_entry(entry)
  local drivers = {}

  local function push(path)
    if type(path) ~= "string" then return end
    -- only binaries that look like compilers
    if path:find("gcc$") or path:find("g%+%+$") or path:find("clang$") or path:find("clang%+%+$") then
      table.insert(drivers, path)
    end
  end

  if entry.arguments and type(entry.arguments) == "table" then
    -- arguments form: ["ccache","/path/to/aarch64-none-elf-g++","-I",...]
    for i = 1, math.min(3, #entry.arguments) do
      local tok = entry.arguments[i]
      if tok and not tok:find("ccache") and not tok:find("sccache") then
        push(tok); break
      end
    end
  elseif entry.command and type(entry.command) == "string" then
    -- command form: "/usr/bin/ccache /opt/.../aarch64-none-elf-g++ -I ..."
    local head = entry.command
    -- first two tokens cover the common ccache/sccache case
    local first, second = head:match('^%s*"(.-)"%s+("(.-)")')
    if not first then
      -- unquoted tokens
      local t1, t2 = head:match("^%s*(%S+)%s+(%S+)")
      first, second = t1, t2
    end

    local function strip_quotes(s) return s and s:gsub('^"(.*)"$', "%1") or s end
    first, second = strip_quotes(first), strip_quotes(second)

    if first and (first:find("ccache") or first:find("sccache")) then
      push(second)
    else
      push(first)
    end
  end

  return drivers
end

-- Public: build a comma-separated --query-driver value (or nil if none)
function M.compute_query_driver(opts)
  opts = opts or {}
  local root = opts.root_dir or vim.fn.getcwd()
  local ccjson = find_ccjson(root, opts.compile_commands_dir)

  if not ccjson then return nil end
  local s = read_file(ccjson); if not s or s == "" then return nil end

  local ok, data = pcall(vim.json.decode, s)
  if not ok or type(data) ~= "table" then return nil end

  -- collect & dedupe
  local seen, list = {}, {}
  for _, entry in ipairs(data) do
    for _, drv in ipairs(extract_driver_from_entry(entry)) do
      if not seen[drv] then
        seen[drv] = true
        table.insert(list, drv)
      end
    end
  end

  if #list == 0 then return nil end

  -- clangd accepts comma-separated patterns; exact paths are fine too.
  -- If you prefer globs per directory, convert to dirname.."/*" here.
  -- We'll pass exact binaries for precision.
  return table.concat(list, ",")
end

return M
