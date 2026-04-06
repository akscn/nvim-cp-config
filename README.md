# Neovim CP Setup (LazyVim)

Competitive programming + regular C++ workflow in Neovim with LazyVim.

---

## Keybinds

| Key | What it does |
|-----|-------------|
| `F4` | Open CP layout — splits into code / input.txt / output.txt |
| `F5` | Simple compile + run — output pops in a terminal below (works anywhere) |
| `F6` | CP compile + run — auto-saves, feeds input.txt, dumps to output.txt |

---

## Layout (F4)

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

### 1. Add keymaps

Copy `keymaps.lua` to:

```
~/.config/nvim/lua/config/keymaps.lua
```

### 2. Add fish function

Add this to `~/.config/fish/config.fish` inside the `if status is-interactive` block:

```fish
# CP folder creator
function mkcp
    mkdir -p $argv
    touch $argv/input.txt $argv/output.txt
end
```

Then reload fish:

```bash
source ~/.config/fish/config.fish
```

### 3. Create your CP folder structure

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
2. `F4` — open layout (once per session)
3. `Ctrl+w l` — jump to input.txt, type test case
4. `Ctrl+w h` — back to code
5. `F6` — output appears instantly in bottom right pane
6. Repeat step 5 forever

### Regular C++

```bash
cd ~/Dev/cpp
nvim hello.cpp
```

Inside nvim:
1. Write your code
2. `F5` — compiles and runs, output pops below

---

## Requirements

- Neovim with LazyVim
- `g++` installed
- Fish shell (for `mkcp` function)
