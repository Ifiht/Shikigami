#!/bin/env bash

echo "Starting core..."
# The default directory pm2 runs from is the root of the repo,
# so we have to specify the relative path including src/
bundle exec ruby src/core.rb
