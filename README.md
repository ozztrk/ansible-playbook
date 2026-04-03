# How to Run the Playbook

## If Ansible is already installed
1. Navigate to the playbook directory:
   ```bash
   cd ansible-playbook
   ```
2. Run the playbook targeting your local machine:
   ```bash
   ansible-playbook site.yml --ask-become-pass
   ```

## If Ansible is not installed
1. Make the setup script executable:
   ```bash
   chmod +x setup.sh
   ```
2. Run the setup script (it installs prerequisites and then executes the playbook):
   ```bash
   ./setup.sh
   ```