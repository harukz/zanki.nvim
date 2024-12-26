local mod = require("zanki.basic")
local py = require("zanki.py_run")

local functions = {
  -- lua functions
  makefile = mod.makefile_embed,
  makeidea = mod.makeidea_embed,
  follow_link = mod.follow_link,
  next_link = mod.next_link,
  prev_link = mod.prev_link,
  safe_del = mod.safe_del,
  copy_link = mod.copy_link,
  insert_alias = mod.insert_alias,
  open_random = mod.open_random,
  bullet = mod.bullet,
  enumerate = mod.enumerate,
  toggle_todo = mod.toggle_todo,
  set_frontmatter = mod.set_frontmatter,
  find_alias = mod.find_alias,
  find_link = mod.find_link,
  find_title = mod.find_title,
  find_files = mod.find_files,
  insert_dependency = mod.insert_dependency,
  restore_file = mod.restore_file,

  -- python programs
  summarize = py.summarize,
  show_parent = py.show_parent,
  show_child = py.show_child,
  formatter = py.formatter,
  backup = py.backup,
  image_compile = py.image_compile,
  sync = py.sync,
  suspended = py.suspended,
  orphan = py.orphan,
  A2Z = py.A2Z,
  Z2A = py.Z2A,
  susZ2A = py.susZ2A,
  susA2Z = py.susA2Z,
  syncAnki = py.syncAnki,
}

local function getKeys(tbl)
  local keys = {}
  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end
  return keys
end

local function key_mapper()
  vim.api.nvim_create_user_command('MD',
    function(opts)
      local func = functions[opts.fargs[1]]
      if func then
        func(opts)
      else
        print("Function not found: " .. opts.fargs[1])
      end
    end,
    {
      nargs = 1,
      range = true,
      complete = function(ArgLead, CmdLine, CursorPos)
        return getKeys(functions)
      end,
    })
end

return {
  key_mapper = key_mapper
}
