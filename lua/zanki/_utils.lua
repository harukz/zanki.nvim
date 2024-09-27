local M = {}

function M.file_check_open(pathes)
  -- open file if exists
  local found = false
  for i = 1, #pathes do
    if found then break end
    local f = io.open(pathes[i], "r")
    if f ~= nil then
      found = true
      io.close(f)
      vim.api.nvim_command(":e " .. pathes[i])
      vim.api.nvim_win_set_cursor(0, { 8, 0 })
    end
  end
  if not found then print("file does not exist!") end
end

function M.scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls ' .. directory)
  if pfile ~= nil then
    for filename in pfile:lines() do
      i = i + 1
      t[i] = filename
    end
    pfile:close()
  end
  return t
end

function M.insert(target)
  local pos = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local nline = line:sub(0, pos) .. target .. line:sub(pos + 1)
  vim.api.nvim_set_current_line(nline)
end

function M.linesbackward(filename)
  local file = assert(io.open(filename))
  local chunk_size = 4 * 1024
  local iterator = function() return "" end
  local tail = ""
  local chunk_index = math.ceil(file:seek "end" / chunk_size)
  return
      function()
        while true do
          local lineEOL, line = iterator()
          if lineEOL ~= "" then
            return line:reverse()
          end
          repeat
            chunk_index = chunk_index - 1
            if chunk_index < 0 then
              file:close()
              iterator = function()
                error('No more lines in file "' .. filename .. '"', 3)
              end
              return
            end
            file:seek("set", chunk_index * chunk_size)
            local chunk = file:read(chunk_size)
            local pattern = "^(.-" .. (chunk_index > 0 and "\n" or "") .. ")(.*)"
            local new_tail, lines = chunk:match(pattern)
            iterator = lines and (lines .. tail):reverse():gmatch "(\n?\r?([^\n]*))"
            tail = new_tail or chunk .. tail
          until iterator
        end
      end
end

function Mysplit(inputstr, sep)
  if sep == nil then
    sep = ","
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function M.get_alias(filename)
  for line in io.open(filename):lines() do
    local pos = string.find(line, "aliases: ")
    if (pos ~= nil) then
      local alias_text = string.sub(line, string.find(line, "%[") + 1, string.find(line, "%]") - 1)
      local aliases = Mysplit(alias_text, ",")
      return aliases
    end
  end
end

return M
