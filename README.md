# How to Run the Playbook

## If Ansible is Already Installed
1. Navigate to the playbook directory:
   ```bash
   cd ansible-playbook
2. Run the playbook
   ```bash
   ansible-playbook main.yml --ask-become-pass
## If Ansible is Not Installed
1. Make the setup script executable
   ```bash
   chmod +x setup.sh
2. Run the setup scrupt:
   ```bash
   ./setup.sh

This will isntall the required dependencies and execute the playbook.