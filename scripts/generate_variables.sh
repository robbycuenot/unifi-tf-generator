#!/bin/bash

# Gather variables from all unifi_*.tf files
vars=$(grep -h -o -E 'var\.[a-zA-Z0-9_-]*' unifi_*.tf | sort | uniq | sed 's/var.//g')

# Clear existing files or create them if they don't exist
> variables.tf

# Write the variables to variables.tf
for var in $vars; do
    echo "variable \"$var\" {" >> variables.tf
    echo "  type = string" >> variables.tf
    echo "  sensitive = true" >> variables.tf
    echo "}" >> variables.tf
    echo "" >> variables.tf
done