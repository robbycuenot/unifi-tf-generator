# Use the latest Microsoft universal image for Codespaces
FROM mcr.microsoft.com/devcontainers/universal:latest

# Install Terraform CLI
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && sudo apt-get update && sudo apt-get install terraform

# Add an alias for 'tf' to call 'terraform' and set ownership to the codespace user
RUN echo 'alias tf="terraform"' >> /home/codespace/.bashrc \
    && echo 'alias tf="terraform"' >> /home/codespace/.profile \
    # Change ownership to the codespace user
    && chown codespace:codespace /home/codespace/.bashrc /home/codespace/.profile
