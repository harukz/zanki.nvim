local M = {}

M.defaults = {}

M.defaults.newfile_template =
[[---
aliases: []
parents: []
tags: []
type: concept
---




---
[Memo]


---]]

M.defaults.filename_format = "%Y%m%d%H%M%S"
M.defaults.slipbox_dir = "./Slipbox"
M.defaults.inbox_dir = "./Inbox"
M.defaults.ideabox_dir = "./Ideabox"

M.defaults.search_pathes = {
  "./Inbox/%s.md",
  "./Slipbox/%s.md",
  "./Ideabox/%s.md",
  "%s.md",
  "%s",
}

M.config = {}

function M.set(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})
end

return M
