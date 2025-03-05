local u = require("zanki._utils")
local opts = require("zanki._config").options

local M = {}

-- Base

function M.makefile_embed()
  local filename = os.date(opts.filename_format)
  local file = opts.slipbox_dir .. "/" .. filename .. ".md"
  local f = io.open(file, "w")
  if (f == nil) then
    vim.api.nvim_notify(string.format("ERROR: Slipbox directory `%s` does not exist.\nPlease create.", opts.slipbox_dir), 1, {})
    return
  end
  f:write(opts.newfile_template)
  f:close()
  u.insert(string.format("[[%s]]", filename))
  vim.api.nvim_command(":e " .. file)
  vim.api.nvim_win_set_cursor(0, { 8, 0 })
end

function M.makeidea_embed()
  local filename = os.date(opts.filename_format)
  local file =  opts.ideabox_dir .. "/" .. filename .. ".md"
  local f = io.open(file, "w")
  if (f == nil) then
    vim.api.nvim_notify(string.format("ERROR: Slipbox directory `%s` does not exist.\nPlease create.", opts.slipbox_dir), 1, {})
    return
  end
  f:write(opts.newfile_template)
  f:close()
  u.insert(string.format("[[%s]]", filename))
  vim.api.nvim_command(":e " .. file)
  vim.api.nvim_win_set_cursor(0, { 8, 0 })
end

function M.daily()
  local filename = os.date(opts.daily_format)
  local file = opts.log_dir .. "/" .. filename .. ".md"

  local file_obj = io.open(file, "r")
  if file_obj then
    vim.api.nvim_command(":e " .. file)
  else
    file_obj = io.open(file, "w")
    file_obj:close()
  end
end

function M.follow_link()
  local link, st, ed = u.get_link()
  if (link ~= nil) then
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    if (st <= pos and pos <= ed) then
      u.file_check_open(link)
    end
  end
end

function M.next_link()
  local i = 0
  for line in io.open(vim.api.nvim_buf_get_name(0)):lines() do
    i = i + 1
    if (vim.api.nvim_win_get_cursor(0)[1] < i) then
      local pos = string.find(line, "%[%[")
      if (pos ~= nil) then
        vim.api.nvim_win_set_cursor(0, { i, pos })
        break
      end
      pos = string.find(line, "# ")
      if (pos ~= nil) then
        vim.api.nvim_win_set_cursor(0, { i, pos })
        break
      end
    end
  end
end

function M.prev_link()
  local n = vim.api.nvim_buf_line_count(0) - vim.api.nvim_win_get_cursor(0)[1] + 1
  local i = 0
  for line in u.linesbackward(vim.api.nvim_buf_get_name(0)) do
    i = i + 1
    if (i > n) then
      local pos = string.find(line, "%[%[")
      if (pos ~= nil) then
        local ll = vim.api.nvim_buf_line_count(0) - i + 1
        vim.api.nvim_win_set_cursor(0, { ll, pos })
        break
      end
      pos = string.find(line, "# ")
      if (pos ~= nil) then
        local ll = vim.api.nvim_buf_line_count(0) - i + 1
        vim.api.nvim_win_set_cursor(0, { ll, pos })
        break
      end
    end
  end
end

function M.safe_del()
  local path = vim.fn.expand('%:p')
  local title = vim.fn.expand('%:t')
  vim.api.nvim_command(":bdelete")
  os.rename(path, ".recycle/" .. title)
end

function M.copy_link()
  local filename = string.sub(vim.fn.expand('%:t'), 1, -4)
  local link_cmd = "[[" .. filename .. "]]"
  vim.fn.setreg('"', link_cmd)
end

function M.insert_alias()
  local pos = vim.api.nvim_win_get_cursor(0)[1]
  local all = io.open(vim.api.nvim_buf_get_name(0)):read("*a")
  if (string.find(all, "|")) then
    vim.api.nvim_command(":%s/|.*]]/]]")
  end
  vim.cmd('w')
  local i = 0
  for line in io.open(vim.api.nvim_buf_get_name(0)):lines() do
    i = i + 1
    local st = string.find(line, "%[%[")
    if (st ~= nil) then
      local vert = string.find(line, "|")
      if (vert == nil) then
        local link = string.sub(line, st + 2, st + 15)

        local main_alias = ""
        for i = 1, #(opts.search_pathes) do
          local file = string.format(opts.search_pathes[i], link)
          local f = io.open(file, "r")
          if f ~= nil then
            io.close(f)
            main_alias = (vim.inspect(u.get_alias(file)[1]))
            break
          end
        end

        if (main_alias ~= nil) then
          main_alias = string.gsub(main_alias, '"', "")
          line = string.gsub(line, link, link .. "|" .. main_alias)
          vim.api.nvim_buf_set_lines(0, i - 1, i, false, { line })
        end
      end
    end
  end
  vim.cmd('w')
  vim.api.nvim_win_set_cursor(0, { pos, 0 })
end

-- MD utils

function M.open_random()
  local t = u.scandir("./Slipbox")
  local choice = t[math.random(#t)]
  vim.api.nvim_command(":e " .. "./Slipbox/" .. choice)
  vim.api.nvim_win_set_cursor(0, { 8, 0 })
end

function M.bullet()
  local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
  local lines = vim.fn.getline(start_line, end_line)
  local is_bulleted = true
  for _, line in ipairs(lines) do
    if not string.match(line, "^%s*%-%s?") then
      is_bulleted = false
      break
    end
  end

  local modified_lines = {}
  for _, line in ipairs(lines) do
    local modified_line
    if is_bulleted then
      modified_line = string.gsub(line, "^%s*%-%s?", "")
    else
      modified_line = "- " .. line
    end
    table.insert(modified_lines, modified_line)
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, modified_lines)
  vim.fn.cursor(start_line, 1)
end

function M.enumerate()
  local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
  for line = start_line, end_line do
    local current_line = vim.fn.getline(line)
    if current_line:match("^%d+%. ") then
      current_line = current_line:gsub("^%d+%. ", "")
    else
      current_line = string.format("%d. %s", line - start_line + 1, current_line)
    end
    vim.fn.setline(line, current_line)
  end
end

function M.toggle_todo()
  local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
  for line_num = start_line, end_line do
    local line = vim.fn.getline(line_num)

    local unchecked_pattern = "- %[% %]"
    local checked_pattern = "^%s*- %[x%] "

    if string.match(line, unchecked_pattern) then
      line = string.gsub(line, unchecked_pattern, "- [x]")
    elseif string.match(line, checked_pattern) then
      line = string.gsub(line, checked_pattern, "")
    else
      line = "- [ ] " .. line
    end

    vim.fn.setline(line_num, line)
  end
end

function M.set_frontmatter()
  local pos = vim.api.nvim_win_get_cursor(0)[1]
  local i = 0
  for line in io.open(vim.api.nvim_buf_get_name(0)):lines() do
    i = i + 1
    local st = string.find(line, "# ")
    if (st ~= nil) then
      local li = vim.api.nvim_buf_get_lines(0, i - 1, i, true)
      local title = vim.inspect(li[1]):sub(4, -2)

      vim.api.nvim_command(":%s/aliases: \\[/" .. string.format("aliases: [%s", title))
      break
    end
  end
  vim.cmd('w')
  vim.api.nvim_win_set_cursor(0, { pos, 0 })
end

-- Telescope
function M.find_alias()
  require('telescope.builtin').grep_string({
    search = "aliases: ",
    path_display = { "hidden" },
    file_ignore_patterns = { ".git/", "System", ".recycle" },
  })
end

function M.find_link()
  require('telescope.builtin').grep_string({
    search = "[[|]]",
    path_display = { "hidden" },
    file_ignore_patterns = { ".git/", "System", ".recycle" },
  })
end

function M.find_title()
  require('telescope.builtin').grep_string({
    search = "title: ",
    path_display = { "hidden" },
    file_ignore_patterns = { ".git/", "System", ".recycle" },
  })
end

function M.find_files()
  local opts = {
    search = "aliases: ",
    file_ignore_patterns = { ".git/", "System", ".recycle" },
    path_display = { "hidden" },
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local entry = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        local filename = entry[1]
        local start = string.find(filename, "Slipbox/")
        local ennd = string.find(filename, "md:")
        if (start ~= nil and ennd ~= nil) then
          filename = "[[" .. string.sub(filename, start + 8, ennd - 2) .. "]]"
        end
        vim.cmd('normal i' .. filename)
        vim.cmd.stopinsert()
        vim.cmd('w')
      end)
      return true
    end,
  }

  require("telescope.builtin").grep_string(opts)
end

function M.insert_dependency()
  local opts = {
    search = "aliases: ",
    file_ignore_patterns = { ".git/", "System", ".recycle" },
    path_display = { "hidden" },
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local entry = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        local filename = entry[1]
        local start = string.find(filename, "Slipbox/")
        local ennd = string.find(filename, "md:")
        if (start ~= nil and ennd ~= nil) then
          filename = string.sub(filename, start + 8, ennd - 2)
        end

        local line = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, true)[3]
        if (line == "parents: []") then
          line = "parents: [" .. filename .. "]"
        else
          line = line:gsub("]", ", " .. filename .. "]")
        end

        vim.api.nvim_buf_set_lines(0, 2, 3, false, { line })
        vim.cmd('w')
      end)
      return true
    end,
  }
  require("telescope.builtin").grep_string(opts)
end

function M.restore_file()
  local opts = {
    search = "aliases: ",
    file_ignore_patterns = { "System", "Slipbox" },
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        -- filename is available at entry[1]
        local entry = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        local filename = entry[1]
        local start = string.find(filename, ".recycle/")
        local ennd = string.find(filename, "md:")
        if (start ~= nil and ennd ~= nil) then
          filename = string.sub(filename, start + 9, ennd + 1)
        end
        os.rename("~/Zettel/.recycle/" .. filename, "~/Zettel/Slipbox/" .. filename)
      end)
      return true
    end,
  }

  require("telescope.builtin").grep_string(opts)
end

return M
