#!/bin/bash

# Install Xcode Command Line Tools
echo "Installing Xcode Command Line Tools..."
xcode-select --install || echo "Xcode Command Line Tools already installed."

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

# Check if Ansible is installed
if ! command -v ansible &>/dev/null; then
  echo "Installing Ansible..."
  brew install ansible
else
  echo "Ansible is already installed."
fi

# Run the Ansible playbook
echo "Running Ansible playbook..."
ansible-playbook homebrew_setup.yml --ask-become-pass
