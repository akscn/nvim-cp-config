# Neovim CP Setup (LazyVim)

Competitive programming + regular C++ workflow in Neovim with LazyVim.

---

## Keybinds

| Key | What it does |
|-----|-------------|
| `F6` | Open CP layout — splits into code / input.txt / output.txt |
| `F7` | Simple compile + run — output pops in a terminal below (works anywhere) |
| `F8` | CP compile + run — auto-saves, feeds input.txt, dumps to output.txt |

---

## Layout (F6)

```
┌─────────────────┬──────────────┐
│                 │  input.txt   │
│  solution.cpp   ├──────────────┤
│                 │  output.txt  │
└─────────────────┴──────────────┘
```

---

## Window Navigation

| Key | Move to |
|-----|---------|
| `Ctrl+w h` | left (code) |
| `Ctrl+w l` | right (input/output) |
| `Ctrl+w j` | down (output) |
| `Ctrl+w k` | up (input) |

These are built into Neovim — no configuration needed.

---

## Installation

### Automatic (recommended)

```bash
git clone https://github.com/akscn/nvim-cp-setup
cd nvim-cp-setup
chmod +x setup.sh
./setup.sh
```

That's it. The script handles everything.

### Manual

#### 1. Add keymaps

Copy `keymaps.lua` to:

```
~/.config/nvim/lua/config/keymaps.lua
```

#### 2. Add mkcp function

**Fish:**
```fish
function mkcp
    mkdir -p $argv
    touch $argv/input.txt $argv/output.txt
end
```
Add inside the `if status is-interactive` block in `~/.config/fish/config.fish`

**Bash/Zsh:**
```bash
mkcp() {
    mkdir -p "$1"
    touch "$1/input.txt" "$1/output.txt"
}
```
Add to `~/.bashrc` or `~/.zshrc`

Then reload your shell:
```bash
source ~/.config/fish/config.fish   # fish
source ~/.bashrc                     # bash
source ~/.zshrc                      # zsh
```

#### 3. Create your CP folder structure

```bash
mkcp ~/Dev/cp
mkcp ~/Dev/cp/arrays
mkcp ~/Dev/cp/dp
mkcp ~/Dev/cp/graphs
# etc...
```

---

## Folder Structure

```
~/Dev/cp/
├── input.txt
├── output.txt
├── arrays/
│   ├── input.txt
│   ├── output.txt
│   └── twosum.cpp
├── dp/
│   ├── input.txt
│   ├── output.txt
│   └── knapsack.cpp
└── graphs/
    ├── input.txt
    ├── output.txt
    └── bfs.cpp
```

Every folder needs its own `input.txt` and `output.txt` — use `mkcp` instead of `mkdir` and it handles this automatically.

---

## Workflows

### Competitive Programming

```bash
cd ~/Dev/cp/arrays
nvim twosum.cpp
```

Inside nvim:
1. Write your solution
2. `F6` — open layout (once per session)
3. `Ctrl+w l` — jump to input.txt, type test case
4. `Ctrl+w h` — back to code
5. `F8` — output appears instantly in bottom right pane
6. Repeat step 5 forever

### Regular C++

```bash
cd ~/Dev/cpp
nvim hello.cpp
```

Inside nvim:
1. Write your code
2. `F7` — compiles and runs, output pops below

---

## Requirements

- Neovim with LazyVim
- `g++` installed
