#!/bin/bash
#
# Bootstrap a brand-new Mac with ONE command:
#
#   curl -fsSL https://raw.githubusercontent.com/ozztrk/ansible-playbook/main/setup.sh | bash
#
# What it does, in order:
#   1. Xcode Command Line Tools (waits until the GUI installer finishes)
#   2. Homebrew
#   3. Ansible (+ community.general collection)
#   4. Clones/updates this repository to ~/ansible-playbook and re-executes
#      itself from disk (so the rest also works when piped through curl)
#   5. Runs the full ansible playbook: macOS settings, NVM, all brew packages
#      and casks, dotfiles clone + stow
#   6. Optional interactive setup of ~/.secrets.zsh (API keys)
#   7. Optional `gh auth login`
#   8. Prints a checklist of the few remaining manual steps
#
set -euo pipefail

REPO_URL="https://github.com/ozztrk/ansible-playbook.git"
REPO_DIR="$HOME/ansible-playbook"

info() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

### --- 1. Xcode Command Line Tools --- ###
info "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  echo "Starting the installer — please confirm the dialog."
  xcode-select --install || true
  # The installer runs in the background; wait until it is done.
  until xcode-select -p &>/dev/null; do sleep 5; done
fi
echo "Xcode Command Line Tools: OK"

### --- 2. Homebrew --- ###
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "Homebrew: OK"

### --- 3. Ansible --- ###
info "Checking Ansible..."
if ! command -v ansible-playbook &>/dev/null; then
  brew install ansible
fi
if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.general'; then
  ansible-galaxy collection install community.general
fi
echo "Ansible: OK"

### --- 4. Clone this repo and re-execute from disk --- ###
# When run via `curl | bash`, stdin is the pipe — cloning and re-executing
# makes the rest of the script independent of it.
if [ ! -f "$REPO_DIR/site.yml" ]; then
  info "Cloning $REPO_URL to $REPO_DIR..."
  git clone "$REPO_URL" "$REPO_DIR"
  exec "$REPO_DIR/setup.sh"
fi
cd "$REPO_DIR"

### --- 5. Run the playbook --- ###
info "Running the Ansible playbook (macOS settings, NVM, Homebrew packages, dotfiles)..."
ansible-playbook site.yml

### --- 6. Secrets --- ###
# ~/.secrets.zsh is sourced by ~/.zshrc but intentionally not tracked in git.
if [ ! -f "$HOME/.secrets.zsh" ]; then
  info "Setting up ~/.secrets.zsh (API keys, not tracked in git)"
  ANTHROPIC_KEY=""
  read -r -s -p "Anthropic API key (press Enter to skip): " ANTHROPIC_KEY </dev/tty || true
  echo ""
  if [ -n "$ANTHROPIC_KEY" ]; then
    umask 077
    printf 'export ANTHROPIC_API_KEY="%s"\n' "$ANTHROPIC_KEY" > "$HOME/.secrets.zsh"
    chmod 600 "$HOME/.secrets.zsh"
    echo "Saved to ~/.secrets.zsh (chmod 600)."
  else
    echo "Skipped. Create it later with:"
    echo '  echo '"'"'export ANTHROPIC_API_KEY="..."'"'"' > ~/.secrets.zsh && chmod 600 ~/.secrets.zsh'
  fi
fi

### --- 7. GitHub CLI auth (optional) --- ###
if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
  ANSWER=""
  read -r -p "Log in to GitHub CLI now? [y/N] " ANSWER </dev/tty || true
  if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
    gh auth login </dev/tty || true
  fi
fi

### --- 8. Remaining manual steps --- ###
info "Done! Remaining manual steps:"
cat <<'EOF'
  1. Restart the terminal (better: log out/in) so macOS settings apply.
  2. 1Password: sign in and enable the SSH agent
     (Settings > Developer) — required for SSH commit signing.
  3. If skipped: create ~/.secrets.zsh and run `gh auth login`.
EOF
