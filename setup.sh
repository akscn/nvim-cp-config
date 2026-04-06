#!/usr/bin/env bash

echo "==> Setting up Neovim CP workflow..."

# ── 1. Add mkcp to config.fish ─────────────────────────────────────────────
FISH_CONFIG="$HOME/.config/fish/config.fish"

if grep -q "function mkcp" "$FISH_CONFIG"; then
  echo "✓ mkcp already in config.fish, skipping"
else
  cat >> "$FISH_CONFIG" << 'FISH'

# CP folder creator
function mkcp
    mkdir -p $argv
    touch $argv/input.txt $argv/output.txt
end
FISH
  echo "✓ mkcp added to config.fish"
fi

# ── 2. Create input.txt and output.txt in ~/Dev/cp ─────────────────────────
mkdir -p "$HOME/Dev/cp"
touch "$HOME/Dev/cp/input.txt" "$HOME/Dev/cp/output.txt"
echo "✓ input.txt and output.txt created in ~/Dev/cp"

# ── 3. Write keymaps.lua ───────────────────────────────────────────────────
KEYMAPS="$HOME/.config/nvim/lua/config/keymaps.lua"

cat > "$KEYMAPS" << 'LUA'
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Normal cpp run (works for any .cpp file anywhere)
-- F7: compiles and runs, output pops in a small terminal below
vim.keymap.set("n", "<F7>", function()
  local file = vim.fn.expand("%:p")
  local bin = vim.fn.expand("%:p:r")
  vim.cmd("botright 10split")
  vim.cmd("terminal cd " .. vim.fn.expand("%:p:h") .. " && g++ -g " .. file .. " -o " .. bin .. " && " .. bin)
  vim.cmd("startinsert")
end, { desc = "Run: simple compile + run" })

-- CP layout opener (press once per session)
-- F6: splits into code | input.txt / output.txt layout
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
-- F8: saves all buffers, compiles, feeds input.txt, writes output.txt
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
LUA

echo "✓ keymaps.lua written"

# ── 4. Done ────────────────────────────────────────────────────────────────
echo ""
echo "✓ All done! Now:"
echo "  1. Restart your terminal (or run: source ~/.config/fish/config.fish)"
echo "  2. Use mkcp to create new CP folders: mkcp ~/Dev/cp/arrays"
echo ""
echo "  Keybinds:"
echo "  F6 → open CP layout"
echo "  F7 → simple compile + run"
echo "  F8 → CP compile + run with input/output"
