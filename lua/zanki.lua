local function set_path()
  local plugin_name = "zanki.nvim"
  local runtime_paths = vim.api.nvim_list_runtime_paths()
  for _, path in ipairs(runtime_paths) do
    if string.find(path, plugin_name) then
      NV_TEST_PLUGIN_DIR = path
    end
  end
end


local function setup(opts)
  set_path()
  local config = require("zanki._config")
  config.set(opts)
  local key = require("zanki.key_mapper")
  key.key_mapper()
end

return {
  setup = setup,
}
