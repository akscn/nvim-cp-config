-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Multi-language run (F7)
vim.keymap.set("n", "<F7>", function()
  vim.cmd("silent! wall")
  local file = vim.fn.expand("%:p")
  local dir  = vim.fn.expand("%:p:h")
  local bin  = vim.fn.expand("%:p:r")
  local ext  = vim.fn.expand("%:e")

  local cmd
  if ext == "cpp" then
    cmd = "cd " .. dir .. " && g++ -g " .. file .. " -o " .. bin .. " && " .. bin
  elseif ext == "py" then
    cmd = "cd " .. dir .. " && python3 " .. file
  elseif ext == "js" then
    cmd = "cd " .. dir .. " && node " .. file
  else
    vim.notify("Unsupported filetype: " .. ext, vim.log.levels.WARN)
    return
  end

  vim.cmd("botright 10split")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end, { desc = "Run: compile + run (cpp/py/js)" })

-- CP layout
vim.keymap.set("n", "<F6>", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):match("input%.txt$") then
      vim.notify("CP layout already open", vim.log.levels.WARN)
      return
    end
  end
  vim.cmd("vsplit input.txt")
  vim.cmd("split output.txt")
  vim.cmd("wincmd h")
end, { desc = "CP: open layout" })

-- CP run
vim.keymap.set("n", "<F8>", function()
  vim.cmd("silent! wall")
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local bin = vim.fn.expand("%:p:r")
  local cmd = string.format("cd %s && g++ -g %s -o %s && %s < input.txt > output.txt", dir, file, bin, bin)
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Build failed:\n" .. result, vim.log.levels.ERROR)
  else
    vim.notify("✓ Done!", vim.log.levels.INFO)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):match("output%.txt$") then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("e!")
        end)
      end
    end
  end
end, { desc = "CP: compile + run with input/output" })
