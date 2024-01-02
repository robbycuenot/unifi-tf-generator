# UniFi Terraform Configuration Generator

## Overview
This repository facilitates the creation of a complete Terraform configuration for managing Ubiquiti UniFi environments. It leverages bash, jq, and curl to automate the extraction, manipulation, and generation of Terraform configurations specific to UniFi devices and settings.

## Repository Structure

### `/scripts`
This directory is the heart of the repository, containing a suite of bash scripts which interact with the UniFi Controller API to fetch and generate necessary data. These scripts use `jq` for JSON parsing and `curl` for API interactions. Key script categories include:

- **Data Retrieval Scripts**: (`get_*.sh`) Fetch data from UniFi controllers for existing configurations, which can then be used in generating Terraform configurations.
- **Generation Scripts**: (`generate_*.sh`) Create Terraform configuration files for various UniFi components like networks, WLANs, user groups, etc.
- **Utility Scripts**: (`*_utils.sh`) Provide supporting functions such as JSON manipulation and Terraform configuration assistance.

### Other Directories and Files
- `/.devcontainer`: Contains container configurations for codespaces.
- `/.github/workflows`: GitHub Actions workflow for generating TF code / PRs.
- `/json`: Folder for normalized json data. Raw responses are in `/json/raw`. Json files themselves are excluded from commits via `.gitignore`.
- `/providers.tf`: Terraform provider setup.
- `/README.md`: This README file.

## Getting Started

### Prerequisites
- A functioning Ubiquiti UniFi setup.
- Basic understanding of bash, jq, and curl.
- Terraform installed on your system.

### Installation and Setup
1. Clone the repository.
2. Ensure you have `bash`, `jq`, and `curl` installed on your system.
3. Set up your UniFi Controller access credentials and other necessary configurations.

### Usage
- Run the appropriate scripts from the `/scripts` directory to fetch data from your UniFi Controller and generate Terraform configurations.
- Use the generated Terraform configurations to manage your UniFi environment.

## Contributing
Contributions are welcome! Please read the contributing guidelines for ways to help improve this project.

## License
This project is released under the [LICENSE NAME], see the LICENSE file for more details.

## Contact
For any queries or contributions, please contact [MAINTAINER'S CONTACT INFORMATION].
