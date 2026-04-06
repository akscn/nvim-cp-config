#!/usr/bin/env bash

echo ""
echo "======================================"
echo "   Neovim CP Setup — LazyVim"
echo "======================================"
echo ""

# ── Requirements check ─────────────────────────────────────────────────────
echo "==> Checking requirements..."

MISSING=0

if ! command -v nvim &> /dev/null; then
  echo "✗ Neovim not found — install it first"
  MISSING=1
else
  echo "✓ Neovim found"
fi

if ! command -v g++ &> /dev/null; then
  echo "✗ g++ not found — install it with: sudo pacman -S gcc"
  MISSING=1
else
  echo "✓ g++ found"
fi

if [ ! -d "$HOME/.config/nvim/lua/config" ]; then
  echo "✗ LazyVim config not found at ~/.config/nvim/lua/config"
  MISSING=1
else
  echo "✓ LazyVim config found"
fi

if [ $MISSING -eq 1 ]; then
  echo ""
  echo "✗ Missing requirements. Fix the above and re-run."
  exit 1
fi

echo ""

# ── Detect shell and add mkcp ───────────────────────────────────────────────
echo "==> Detecting shell..."

CURRENT_SHELL=$(basename "$SHELL")
echo "✓ Default shell: $CURRENT_SHELL"

add_mkcp_fish() {
  FISH_CONFIG="$HOME/.config/fish/config.fish"
  if [ ! -f "$FISH_CONFIG" ]; then
    echo "✗ Fish config not found at $FISH_CONFIG"
    return
  fi
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
}

add_mkcp_bash() {
  BASH_CONFIG="$HOME/.bashrc"
  if grep -q "function mkcp" "$BASH_CONFIG" || grep -q "mkcp()" "$BASH_CONFIG"; then
    echo "✓ mkcp already in .bashrc, skipping"
  else
    cat >> "$BASH_CONFIG" << 'BASH'

# CP folder creator
mkcp() {
    mkdir -p "$1"
    touch "$1/input.txt" "$1/output.txt"
}
BASH
    echo "✓ mkcp added to .bashrc"
  fi
}

add_mkcp_zsh() {
  ZSH_CONFIG="$HOME/.zshrc"
  if grep -q "function mkcp" "$ZSH_CONFIG" || grep -q "mkcp()" "$ZSH_CONFIG"; then
    echo "✓ mkcp already in .zshrc, skipping"
  else
    cat >> "$ZSH_CONFIG" << 'ZSH'

# CP folder creator
mkcp() {
    mkdir -p "$1"
    touch "$1/input.txt" "$1/output.txt"
}
ZSH
    echo "✓ mkcp added to .zshrc"
  fi
}

case "$CURRENT_SHELL" in
  fish) add_mkcp_fish ;;
  bash) add_mkcp_bash ;;
  zsh)  add_mkcp_zsh ;;
  *)
    echo "! Unknown shell: $CURRENT_SHELL"
    echo "  Manually add mkcp to your shell config — see README"
    ;;
esac

echo ""

# ── Create ~/Dev/cp with input/output ──────────────────────────────────────
echo "==> Creating ~/Dev/cp..."
mkdir -p "$HOME/Dev/cp"
touch "$HOME/Dev/cp/input.txt" "$HOME/Dev/cp/output.txt"
echo "✓ ~/Dev/cp ready with input.txt and output.txt"

echo ""

# ── Write keymaps.lua ───────────────────────────────────────────────────────
echo "==> Writing keymaps.lua..."

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

echo ""
echo "======================================"
echo "✓ Setup complete!"
echo "======================================"
echo ""
echo "  Restart your terminal, then:"
echo "  → Use mkcp to create CP subfolders:"
echo "    mkcp ~/Dev/cp/arrays"
echo "    mkcp ~/Dev/cp/dp"
echo ""
echo "  Keybinds in Neovim:"
echo "  F6 → open CP layout"
echo "  F7 → simple compile + run"
echo "  F8 → CP compile + run with input/output"
echo ""
