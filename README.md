# Ansible Mac Setup

Fully automated setup for a new Mac: macOS preferences, NVM/Node.js, all
Homebrew packages and apps, and the
[dotfiles](https://github.com/ozztrk/dotfiles) (cloned + symlinked with GNU Stow).

## What it does

| Step | File | Description |
| --- | --- | --- |
| macOS preferences | `mac_settings.yml` | Dock (auto-hide, left), Dark Mode, menu bar items, hidden desktop icons, natural scrolling off |
| NVM | `nvm_setup.yml` | Installs [nvm](https://github.com/nvm-sh/nvm) into `~/.nvm` + latest LTS Node.js |
| Homebrew | `homebrew_setup.yml` | Taps, CLI formulae and GUI casks — the single source of truth for installed packages |
| Dotfiles | `dotfiles_setup.yml` | Clones the dotfiles repo to `~/dotfiles` and stows the configs into `~` and `~/.config` |

## Usage

### Fresh Mac — one command

```bash
curl -fsSL https://raw.githubusercontent.com/ozztrk/ansible-playbook/main/setup.sh | bash
```

The bootstrap script installs the Xcode Command Line Tools, Homebrew and
Ansible, clones this repo to `~/ansible-playbook`, runs the full playbook
(macOS settings, NVM, all brew packages, dotfiles clone + stow) and then
walks you through the few interactive parts: creating `~/.secrets.zsh`
(API keys) and, optionally, `gh auth login`. It ends with a checklist of
the remaining manual steps (1Password sign-in, terminal restart).

### Already cloned locally

```bash
cd ansible-playbook
./setup.sh                  # full bootstrap
ansible-playbook site.yml   # or just re-apply the configuration
```

No sudo is required — everything runs as the normal user. Do **not** add
`become: true` at play level: `defaults write` would then write root's
preferences instead of yours, and Homebrew refuses to run as root.

## After the run

1. **Restart the terminal** (or log out/in) so shell config and macOS
   settings fully apply.
2. **1Password**: sign in and enable the SSH agent
   (Settings → Developer) — required for SSH commit signing.
3. **Secrets**: the bootstrap already offers to create `~/.secrets.zsh`
   (sourced by `~/.zshrc`, deliberately not tracked in git). If you skipped
   it:
   ```bash
   echo 'export ANTHROPIC_API_KEY="..."' > ~/.secrets.zsh
   chmod 600 ~/.secrets.zsh
   ```
4. Some macOS settings (menu bar, Control Center) only take effect after
   logout/restart.

## Adding or removing packages

Edit `homebrew_setup.yml` only — never install ad-hoc if you want the next
machine to match. After editing, re-run `ansible-playbook site.yml`; all
tasks are idempotent.

To check what is installed locally but missing from the playbook:

```bash
brew leaves          # explicitly installed formulae
brew list --cask     # installed casks
```

## Notes

- If `stow` reports a conflict (e.g. an existing `~/.zshrc` on a machine that
  was used before), back up and remove the conflicting file, then re-run.
- The old `miniconda_setup.yml` is intentionally retired; Python is managed
  with `uv` instead.
