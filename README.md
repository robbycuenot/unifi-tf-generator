# UniFi Terraform Configuration Generator

## Overview
This repository facilitates the creation of a complete Terraform configuration for managing Ubiquiti UniFi environments. It leverages bash, jq, and curl to automate the extraction, manipulation, and generation of Terraform configurations specific to UniFi devices and settings.

## Getting Started

### Prerequisites
- A functioning Ubiquiti UniFi setup. Tested with UDM Pro, but should work for other controllers.
- Basic understanding of bash, jq, and curl.
- An environment with:
    - connectivity to the local Unifi controller endpoint
    - local unifi user account with `admin` access
        - NOTE: `viewer` access will allow creation of some resources, but will be unable to
                access any sensitive fields such as controller SSH settings or radius auth settings.
                Results may be inconsistent. For the moment, consider this unsupported.
    - bash 4.0+
        - Almost every major linux distribution ships with this, though the default may be something else (ksh, zsh). Run `bash` to enter the bash terminal, and `bash --version` to verify that you are on 4.0+
        - Mac OS still ships with bash 3.2 as the default version. This is 10+ years out-of-date, and does not support associative arrays, which are used heavily in this project. The easiest way to correct for this is to install a newer version of bash with brew. This will not overwrite the default shell; the two exist in tandem.
            ```bash
            brew install bash
            ```
            After installing this newer version of bash, it should be added to your `PATH` automatically, and the scripts should automatically reference it. You can verify that you are on v4.0+ by running `bash --version`:

            ```bash
            GNU bash, version 5.2.26(1)-release (x86_64-apple-darwin23.2.0)
            Copyright (C) 2022 Free Software Foundation, Inc.
            License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

            This is free software; you are free to change and redistribute it.
            There is NO WARRANTY, to the extent permitted by law.
            ```

    - curl
    - jq
        - For Ubuntu, this can be achieved with the following script:
          ```
          apt-get install -y jq
          ```
          For Mac OS, this can be achieved with the following script:
          ```
          brew install jq
          ```
    - utf-8 english language support (necessary for parsing some special characters)
        - For Ubuntu, this can be achieved with the following script:
          ```
          apt-get install -y locales
          locale-gen en_US.UTF-8
          LANG=en_US.UTF-8
          LANGUAGE=en_US:en
          LC_ALL=en_US.UTF-8
          ```
        - For Mac OS, this is enabled by default

### Installation and Setup

#### GitHub Codespaces (Recommended)

1. Install the GitHub CLI: https://cli.github.com/
1. Install the Codespaces Network Bridge: https://github.com/github/gh-net
1. Fork this repository
1. Set three codespace secrets:
    1. SECRET_UNIFI_IP
        - Example Value: 192.168.1.1
    1. SECRET_UNIFI_USER
        - Example Value: terraform-generator
    1. SECRET_UNIFI_PASSWORD
        - Example Value: YoUrSuP3rS3cRetP@ssW0rd
1. Launch the codespace
1. In a local terminal, execute `gh net` and connect to your codespace
1. In the codespace, execute:
    `./scripts/all.sh`
1. All terraform code will be generated at the root level of the repository

#### Local Execution

1. Clone the repository.
1. Execute `./scripts/all.sh -i $YOURIP -u $YOURUSER -p $YOURPASSWORD`
    - Alternatively, set the environment variables `SECRET_UNIFI_IP` `SECRET_UNIFI_USER` and `SECRET_UNIFI_PASSWORD` and run `./scripts/all.sh`
1. All terraform code will be generated at the root level of the repository

#### GitHub Actions

1. Create a github self-hosted runner, with the capabilities listed in Actions_Dockerfile, on your home network
1. A prebuilt image is available at docker.io/robbycuenot/gh-runner-ubuntu:latest, built from that file
1. Launch that container with the following environment variables:
    - RUNNER_TOKEN=YOURGHRUNNERTOKEN
    - REPO_URL=https://github.com/youraccountororganizationname
    - RUNNER_NAME=gh-runner-ubuntu
    - RUNNER_WORKDIR=_work
    - **NOTE:** You may want to configure persistent volumes, otherwise you will have to re-register the container
      every time it restarts. I've tried to lay the groundwork for mounting /home/runner, however podman permissions
      for volumes are frustrating as hell and I've not been able to get it working. PRs welcome if you have a fix.
1. Verify that your container has started and successfully registered with GitHub
1. Under repository settings, check `Allow GitHub Actions to create and approve pull requests`.
1. Invoke the `Unifi Refresh` workflow, selecting `all` to generate code for the entire Unifi network.

## Repository Structure

### `/scripts`
This directory is the heart of the repository, containing a suite of bash scripts which interact with the UniFi Controller API to fetch and generate necessary data. These scripts use `jq` for JSON parsing and `curl` for API interactions. Key script categories include:

- **Data Retrieval Scripts**: (`get_*.sh`) Fetch data from UniFi controllers for existing configurations, which can then be used in generating Terraform configurations.
- **Generation Scripts**: (`generate_*.sh`) Create Terraform configuration files for various UniFi components like networks, WLANs, user groups, etc.
- **Utility Scripts**: (`*_utils.sh`) Provide supporting functions such as JSON manipulation and Terraform configuration assistance.

### Other Directories and Files
- `/.devcontainer`: Contains container configurations for codespaces.
- `/.github/workflows`: GitHub Actions workflow for generating TF code / PRs.
- `/docs`: Reference architecture documents and sample terraform files
- `/json`: Folder for normalized json data. Raw responses are in `/json/raw`. Json files themselves are excluded from commits via `.gitignore`.
- `/log.txt`: Logs generated at runtime. Excluded via `.gitignore`.
- `/providers.tf`: Terraform provider setup. Substitute organization and workspace name as needed for Terraform Cloud
- `/tests`: For now, contains a basic docker container to serve raw json responses at endpoints that mirror a network controller. TODO: Add sample json
- `/README.md`: This README file.

## Contributing
Contributions are welcome! Will write contribution guidelines as this project progresses.
