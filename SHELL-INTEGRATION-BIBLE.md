# Shell Integration Bible
> Cookbook & canonical spec for zenfull & thoughtful shell integrations
> **Version:** 2.0 · **Shell:** zsh · **Layout root:** `~/.zsh/`

This document is the single source of truth for how a shell environment is
structured, extended, and maintained. It is prescriptive on purpose: every
integration follows the same layout, the same load order, and the same output
conventions, so any human *or* agent can drop a new file in the right place and
have it Just Work.

---

## 0. Design philosophy

1. **Deterministic load order.** Nothing is sourced "somewhere". Files are
   numbered and sourced in lexical order. If order matters (and in zsh it
   *always* does), the number says so.
2. **One concern per file.** History config lives in one file, aliases in
   another, plugin declarations in another. You never grep a 400-line `.zshrc`
   again.
3. **`.zshrc` is a loader, not a config.** The real config lives in `~/.zsh/`.
   `.zshrc` only bootstraps and sources. This makes the whole thing portable,
   version-controllable, and diffable.
4. **Automate or script everything.** Manual setup steps are bugs. If a machine
   can be brought from bare zsh to full environment by running one script, we
   did it right.
5. **Pretty + useful output is the baseline.** Syntax highlighting, colored
   listings, aligned columns, and previews are not extras — they are the
   minimum acceptable output.
6. **Idempotent + safe.** Re-running the bootstrap, re-sourcing a file, or
   opening a second shell never breaks state or duplicates work.
7. **Machine-local secrets never live in the repo.** `~/.zsh/local/` is
   gitignored and always sourced last, so per-host overrides win.

---

## 1. Stack

### Core (required)
| Tool | Role | Why it's non-negotiable |
|------|------|--------------------------|
| `zsh` | shell | glob qualifiers, `zstyle`, native completion engine |
| `zinit` | plugin manager | turbo (deferred) loading, snippets, ice modifiers |
| `powerlevel10k` | prompt | instant prompt, near-zero perceived latency |
| `fzf` | fuzzy finder | the backbone of every interactive picker |
| `zoxide` | smarter `cd` | frecency-ranked directory jumping |

### Plugins (via zinit)
| Plugin | Role |
|--------|------|
| `zsh-users/zsh-completions` | extra completion definitions |
| `zsh-users/zsh-autosuggestions` | inline history/completion ghost text |
| `zdharma-continuum/fast-syntax-highlighting` | command-line highlighting (faster successor to `zsh-syntax-highlighting`) |
| `Aloxaf/fzf-tab` | replaces tab completion menu with an fzf picker |

### CLI utilities (installed system-wide)
| Tool | Replaces / adds |
|------|-----------------|
| `bat` | `cat` with syntax highlighting + git gutter |
| `eza` | `ls` with icons, git status, tree view *(preferred over raw `ls --color`)* |
| `fd` | `find`, but sane and fast |
| `ripgrep` (`rg`) | `grep`, but fast and gitignore-aware |
| `highlight` | fallback syntax highlighter for previews |
| `delta` | git diff pager |

### Help / recovery layer (must be present)
| Tool | Purpose |
|------|---------|
| `man` | canonical reference |
| `tldr` | practical, example-first cheatsheets |
| `wtf` (or `cheat`) | quick "what does this do" lookups |
| `thefuck` | corrects the previous mistyped command |

> **Base zen config reference:** https://github.com/Szmelc-INC/Silver-ZSH

---

## 2. Canonical directory layout

Everything lives under one fixed root: **`~/.zsh/`**. This is the only path you
memorize.

```
~/.zsh/
├── rc.d/               # numbered runcommand files, sourced in order by .zshrc
│   ├── 00-init.zsh         # env vars, XDG paths, PATH, guards
│   ├── 10-zinit.zsh        # zinit bootstrap + plugin/snippet declarations
│   ├── 20-completion.zsh   # compinit + zstyle completion styling
│   ├── 30-history.zsh      # HISTFILE, HISTSIZE, setopt hist_*
│   ├── 40-keybinds.zsh     # bindkey
│   ├── 50-aliases.zsh      # alias only
│   ├── 60-functions.zsh    # thin loader: autoload everything in functions/
│   ├── 70-integrations.zsh # fzf, zoxide, tool init (LAST-ish on purpose)
│   └── 90-prompt.zsh       # p10k config source
├── functions/          # one file per function, autoloaded lazily
│   ├── extract
│   ├── mkcd
│   └── ...
├── completions/        # custom/vendored _completion files (added to fpath)
│   └── _mytool
├── bin/                # standalone scripts, added to PATH
│   └── ...
├── conf/               # tool config that isn't a runcommand (p10k.zsh, etc.)
│   └── p10k.zsh
├── local/              # GITIGNORED — per-host secrets & overrides, sourced last
│   └── .gitkeep
├── cache/              # compdump, zcompiled files (gitignored)
└── bootstrap.zsh       # idempotent installer (see §8)
```

### Numbering scheme (leave gaps on purpose)
- `00–09` — environment, must run before anything else
- `10–19` — plugin manager & plugins
- `20–29` — completion system
- `30–39` — history
- `40–49` — keybindings
- `50–59` — aliases
- `60–69` — functions
- `70–89` — external tool integrations
- `90–99` — prompt & final overrides

Gaps mean you can insert `35-history-extra.zsh` later without renumbering.

---

## 3. Rules & conventions

### Standardization
- **Every file is self-contained and re-sourceable.** No file assumes another
  already ran *except* through the documented load order. Guard anything
  order-sensitive.
- **Every file starts with a one-line header comment** stating its single
  concern: `# 30-history.zsh — history behavior only`.
- **One concern per file. No exceptions.** An alias never appears in
  `40-keybinds.zsh`.
- **Naming:** runcommands are `NN-name.zsh`. Functions are lowercase, one file
  per function, filename == function name, no extension (autoload convention).
  Completions are `_name`. Scripts in `bin/` are executable and shebanged.

### Automation
- If a setup step is manual, it belongs in `bootstrap.zsh`.
- Plugins are declared, never hand-cloned. `zinit` owns their lifecycle.
- Re-running bootstrap is always safe (idempotent).

### Output & UX
- Syntax highlighting is the floor, not the ceiling.
- Prefer tools that produce aligned, colored, glanceable output (`eza`, `bat`,
  `delta`).
- Interactive selection = `fzf` with a live preview pane. If a picker has no
  preview, it's unfinished.
- Completions, autosuggestions, and `command-not-found` handling are always on.

### Hygiene
- Secrets and per-machine values → `~/.zsh/local/` only.
- The whole `~/.zsh/` (minus `local/`, `cache/`) is a git repo.
- `local/`, `cache/`, and any `*.zwc` go in `.gitignore`.

---

## 4. Load order — the part that actually matters

zsh is order-sensitive and the failure modes are silent. This is the correct
sequence and *why* each step sits where it does:

1. **p10k instant prompt** — must be near the very top of `.zshrc`. Anything
   that prints or asks for input goes *above* it; everything else below.
2. **Environment / PATH / XDG** (`00-init`) — before plugins so they see the
   right paths.
3. **zinit + plugins** (`10-zinit`) — theme first, then plugins. Heavy plugins
   use turbo (`wait lucid`) so they load *after* the prompt paints.
4. **`compinit`** (`20-completion`) — **before** `fzf-tab`. This is the single
   most common ordering bug.
5. **`fzf-tab`** — after `compinit`, **before** autosuggestions & highlighting,
   because it wraps completion widgets and those two wrap it in turn.
6. **`fast-syntax-highlighting`** — loaded **last** among widget plugins. It
   must see every custom widget already defined or it won't highlight them.
7. **`zsh-autosuggestions`** — after highlighting, so the ghost text isn't
   swallowed by the highlighter.
8. **History, setopt** (`30-history`).
9. **Keybindings** (`40-keybinds`).
10. **Aliases** (`50-aliases`), **functions** (`60-functions`).
11. **Integrations** (`70-integrations`) — `fzf`, then **`zoxide` dead last**,
    because `zoxide init --cmd cd` *defines* `cd`. Anything that touches `cd`
    after this wins and breaks it. (This is exactly the bug in the v1 config.)
12. **Prompt config** (`90-prompt`).

> Turbo/`wait` loading reorders *when* things run relative to the prompt, but
> zinit preserves declaration order among same-`wait` plugins, so the rules
> above still hold.

---

## 5. `.zshrc` — the loader

This is the entire `.zshrc`. It never grows. All real config lives in `rc.d/`.

```sh
# ~/.zshrc — loader only. Real config lives in ~/.zsh/rc.d/
# Powerlevel10k instant prompt. Keep near the top.
# Anything requiring console input (passwords, [y/n]) must go ABOVE this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# macOS homebrew shellenv (harmless/no-op elsewhere)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

export ZDOTDIR_CONF="$HOME/.zsh"

# Source every runcommand in rc.d/, in lexical (numbered) order.
if [[ -d "$ZDOTDIR_CONF/rc.d" ]]; then
  for _rc in "$ZDOTDIR_CONF"/rc.d/*.zsh(N); do
    source "$_rc"
  done
  unset _rc
fi

# Per-host overrides & secrets — always last, never in git.
for _local in "$ZDOTDIR_CONF"/local/*.zsh(N); do
  source "$_local"
done
unset _local
```

> `(N)` is the `NULL_GLOB` qualifier: if the directory is empty the loop
> silently does nothing instead of erroring. This is why re-sourcing is safe.

---

## 6. The rc.d files

### `00-init.zsh`
```sh
# 00-init.zsh — environment, XDG, PATH. Runs before everything.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export EDITOR="nvim"
export PAGER="less"
export ZSH_CACHE="$HOME/.zsh/cache"
mkdir -p "$ZSH_CACHE"

# Prepend personal script dir + fpath for custom functions/completions.
path=("$HOME/.zsh/bin" $path)
fpath=("$HOME/.zsh/functions" "$HOME/.zsh/completions" $fpath)
typeset -U path fpath   # dedupe
```

### `10-zinit.zsh`
```sh
# 10-zinit.zsh — plugin manager + declarations.
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Theme — load immediately (instant prompt already painted).
zinit ice depth=1; zinit light romkatv/powerlevel10k

# fzf-tab must load AFTER compinit — deferred via turbo so 20-completion runs first.
zinit ice wait lucid; zinit light Aloxaf/fzf-tab

# Extra completions (turbo).
zinit ice wait lucid blockf; zinit light zsh-users/zsh-completions

# Highlighting must come before autosuggestions; both deferred.
zinit ice wait lucid; zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice wait lucid atload'_zsh_autosuggest_start'; zinit light zsh-users/zsh-autosuggestions

# Oh-My-Zsh snippets (declarative libs).
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
# add as needed: aws, kubectl, kubectx, docker...

zinit cdreplay -q   # replay cached compdefs collected by blockf
```

### `20-completion.zsh`
```sh
# 20-completion.zsh — completion engine + styling.
autoload -Uz compinit
_zcompdump="$ZSH_CACHE/zcompdump-${ZSH_VERSION}"
# Rebuild dump only if older than 24h, else load cached (fast start).
if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'          # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no                                   # fzf-tab handles menu
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
# fzf-tab previews
zstyle ':fzf-tab:complete:cd:*'          fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*'  fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls --color $realpath'
```

### `30-history.zsh`
```sh
# 30-history.zsh — history behavior only.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=$HISTSIZE
setopt append_history share_history hist_ignore_space \
       hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups \
       hist_reduce_blanks extended_history
```

### `40-keybinds.zsh`
```sh
# 40-keybinds.zsh — bindkey only.
bindkey -e                              # emacs mode
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
```

### `50-aliases.zsh`
```sh
# 50-aliases.zsh — aliases only.
if command -v eza >/dev/null; then
  alias ls='eza --color=auto --group-directories-first'
  alias ll='eza -lah --git --group-directories-first'
  alias tree='eza --tree'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah'
fi
command -v bat >/dev/null && alias cat='bat --paging=never'
command -v nvim >/dev/null && alias vim='nvim'
command -v rg >/dev/null && alias grep='rg'
alias c='clear'
alias reload='exec zsh'   # cleaner than re-sourcing everything
```

### `60-functions.zsh`
```sh
# 60-functions.zsh — autoload every function in ~/.zsh/functions/.
# (fpath already includes it via 00-init.)
for _fn in "$HOME"/.zsh/functions/*(N.:t); do
  autoload -Uz "$_fn"
done
unset _fn
```

### `70-integrations.zsh`
```sh
# 70-integrations.zsh — external tool init. zoxide MUST be last (it owns `cd`).
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
command -v thefuck >/dev/null && eval "$(thefuck --alias)"

# zoxide replaces cd. Do NOT define a cd() function after this line anywhere.
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"
```

### `90-prompt.zsh`
```sh
# 90-prompt.zsh — prompt config.
[[ -f ~/.zsh/conf/p10k.zsh ]] && source ~/.zsh/conf/p10k.zsh
```

---

## 7. Authoring patterns

### A function (one file, `~/.zsh/functions/mkcd`)
```sh
# mkcd — make a dir and cd into it.
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}
```
Filename == function name, no extension. `60-functions.zsh` autoloads it. It's
loaded lazily — the body isn't parsed until first call.

### `~/.zsh/functions/extract` — universal unarchiver
```sh
extract() {
  [[ -f "$1" ]] || { print -u2 "extract: '$1' not found"; return 1; }
  case "$1" in
    *.tar.gz|*.tgz)  tar xzf "$1" ;;
    *.tar.bz2|*.tbz) tar xjf "$1" ;;
    *.tar.xz)        tar xJf "$1" ;;
    *.tar)           tar xf  "$1" ;;
    *.zip)           unzip   "$1" ;;
    *.7z)            7z x    "$1" ;;
    *.gz)            gunzip  "$1" ;;
    *) print -u2 "extract: unknown format '$1'"; return 1 ;;
  esac
}
```

### An alias
Goes in `50-aliases.zsh`. Nowhere else. Guard it with `command -v` if the
target tool might be missing (see the file above).

### A completion
Drop `_toolname` into `~/.zsh/completions/`. It's already on `fpath`; next
`compinit` (or 24h rebuild) picks it up. Force immediate pickup with `reload`.

### A standalone script
Drop it in `~/.zsh/bin/`, `chmod +x`, add a shebang. It's on `PATH`
automatically via `00-init`.

---

## 8. Bootstrap — bare zsh → full environment in one run

`~/.zsh/bootstrap.zsh`. Idempotent. Run once on a new machine.

```sh
#!/usr/bin/env zsh
# bootstrap.zsh — bring a machine to the full shell environment. Safe to re-run.
set -e
ZROOT="$HOME/.zsh"

echo "==> Creating layout"
mkdir -p "$ZROOT"/{rc.d,functions,completions,bin,conf,local,cache}
touch "$ZROOT/local/.gitkeep"

echo "==> Installing CLI utilities (Arch/pacman shown; adapt per distro)"
pkgs=(zsh fzf zoxide bat eza fd ripgrep git-delta man-db tldr thefuck highlight)
if command -v pacman >/dev/null; then
  sudo pacman -S --needed --noconfirm $pkgs
elif command -v brew >/dev/null; then
  brew install ${pkgs/git-delta/delta}
elif command -v apt >/dev/null; then
  sudo apt update && sudo apt install -y zsh fzf bat fd-find ripgrep git tldr thefuck highlight
  # eza/zoxide/delta may need cargo or a newer repo on Debian.
fi

echo "==> Linking .zshrc (backing up any existing one)"
[[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
# Assumes the loader .zshrc from §5 is committed at $ZROOT/zshrc
ln -sf "$ZROOT/zshrc" "$HOME/.zshrc"

echo "==> zinit + plugins install on first shell start"
echo "==> Setting zsh as default shell"
[[ "$SHELL" != *zsh ]] && chsh -s "$(command -v zsh)"

echo "==> Done. Open a new shell, then run: p10k configure"
```

### `.gitignore` for the `~/.zsh/` repo
```
local/*
!local/.gitkeep
cache/
*.zwc
```

---

## 9. Technical notes & gotchas

- **`compinit` security warning.** If completion dirs are group-writable,
  `compinit` nags. `compinit -C` skips the check (fine on a single-user box);
  otherwise `chmod -R go-w ~/.zsh` and let it verify.
- **Compile hot files.** `zcompile ~/.zshrc` and `zcompile` the compdump for a
  measurable startup win. zinit can auto-compile plugins with `zinit
  compile`.
- **Measure startup, don't guess.** `zsh -i -c exit` under `time`, or profile
  with `zmodload zsh/zprof` at the top of `.zshrc` and `zprof` at the bottom.
- **Turbo loading is the big lever.** Everything non-visual gets `wait lucid`
  so it loads after the first prompt paints. Prompt feels instant even with a
  dozen plugins.
- **`typeset -U path fpath`** dedupes automatically — re-sourcing `00-init`
  never bloats your PATH.
- **Never redefine `cd` after zoxide init.** Restated because it's the #1
  self-inflicted breakage.
- **`fast-syntax-highlighting` vs `zsh-syntax-highlighting`:** the fast fork is
  faster and has better theming; if you specifically need the upstream one,
  the ordering rules are identical (load last among widget plugins).
- **`share_history` + `hist_ignore_space`:** commands prefixed with a space are
  never written to history — use it for anything with a secret in the args.

---

## 10. What changed from v1 (and why)

| v1 problem | v2 fix |
|-----------|--------|
| `cd() { builtin cd }` defined *after* zoxide init → **zoxide silently dead** | removed; zoxide owns `cd`, loaded last |
| `fzf-tab` loaded before `compinit`; highlighting before completions | correct order enforced via turbo + numbered files |
| `compinit` with no cache dump | 24h cached dump, `-C` fast path |
| everything in one `.zshrc` | `.zshrc` is a loader; config split into `rc.d/` |
| no lazy loading | heavy plugins deferred with `wait lucid` |
| `zsh-syntax-highlighting` | `fast-syntax-highlighting` (faster fork) |
| plain `ls --color` | `eza` with git + icons, graceful fallback |
| no bootstrap / manual setup | idempotent `bootstrap.zsh` |
| no secrets separation | gitignored `local/`, sourced last |

---

## 11. Sanity checklist

- [ ] `~/.zsh/` exists with all subdirs
- [ ] `.zshrc` is a symlink to `~/.zsh/zshrc` and contains only the loader
- [ ] `for f in rc.d/*.zsh` sources cleanly with no errors (`reload`)
- [ ] `type cd` reports the zoxide function, not the builtin
- [ ] tab-completing `cd <TAB>` opens an fzf picker with a preview pane
- [ ] `echo $path` has no duplicates
- [ ] `zsh -i -c exit` startup is under ~150ms warm
- [ ] `local/` is gitignored and git status is clean
- [ ] `tldr`, `thefuck`, `bat`, `eza`, `fzf`, `zoxide` all resolve on PATH
