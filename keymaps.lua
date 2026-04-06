-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Normal cpp run (works for any .cpp file anywhere)
-- F5: compiles and runs, output pops in a small terminal below
vim.keymap.set("n", "<F7>", function()
  local file = vim.fn.expand("%:p")
  local bin = vim.fn.expand("%:p:r")
  vim.cmd("botright 10split")
  vim.cmd("terminal cd " .. vim.fn.expand("%:p:h") .. " && g++ -g " .. file .. " -o " .. bin .. " && " .. bin)
  vim.cmd("startinsert")
end, { desc = "Run: simple compile + run" })

-- CP layout opener (press once per session)
-- F4: splits into code | input.txt / output.txt layout
-- Won't open twice if layout is already open
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

-- CP run (auto-saves everything before compiling)
-- F6: saves all buffers, compiles, feeds input.txt, writes output.txt
-- output.txt auto-reloads in its pane
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
