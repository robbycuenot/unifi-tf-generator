#!/bin/bash
set -e

# Copy runner files from /tmp/runner_files to /home/runner
cp -r /tmp/runner_files/* /home/runner/

# Change to the runner directory
cd /home/runner

# Check if the runner is already configured
if [ ! -f ".runner" ]; then
    # Configure the runner
    ./config.sh --url ${REPO_URL} --token ${RUNNER_TOKEN} --name ${RUNNER_NAME} --work ${RUNNER_WORKDIR} --unattended --replace
fi

# Start the runner
exec ./run.sh