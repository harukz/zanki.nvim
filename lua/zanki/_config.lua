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


M.config = {}

function M.set(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})
end

return M
