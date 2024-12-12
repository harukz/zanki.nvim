local M = {}

function M.summarize()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/summarize.py ")
  vim.api.nvim_command(":e " .. "./tmp.md")
end


function M.formatter()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/formatter.py ")
  require("notify")("Completed!")
end


function M.A2Z()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/a2z.py ")
  require("notify")("Imported from Anki.", nil, {timeout = -1})
end


function M.Z2A()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/z2a.py ")
  require("notify")("Exported to Anki.", nil, {timeout = -1})
end


-- functions file
function M.sync()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py sync")
  vim.api.nvim_command(":e " .. "./tmp.md")
  require("notify")("Completed!")
end


function M.suspended()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py get_suspended")
  vim.api.nvim_command(":e " .. "./tmp.md")
end


function M.orphan()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py write_orphan")
  vim.api.nvim_command(":e " .. "./tmp.md")
end

function M.susZ2A()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py z2a_sus")
  require("notify")("Sync suspended z2a!")
end

function M.susA2Z()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py a2z_sus")
  require("notify")("Sync suspended a2z!")
end

function M.syncAnki()
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py sync_anki")
  require("notify")("Synced with Anki web.")
end

function M.show_parent()
  local filename = string.sub(vim.fn.expand('%:t'), 1, -4)
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py show_parent " .. filename)
  vim.api.nvim_command(":e " .. "./tmp.md")
end

function M.show_child()
  local filename = string.sub(vim.fn.expand('%:t'), 1, -4)
  os.execute("python " .. NV_TEST_PLUGIN_DIR .. "/programs/functions.py show_child " .. filename)
  vim.api.nvim_command(":e " .. "./tmp.md")
end


return M
