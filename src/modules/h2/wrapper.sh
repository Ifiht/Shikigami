#!/bin/env bash

echo "Starting H2 server..."

java -cp h2*.jar org.h2.tools.Server -pg -baseDir ./data -properties "./data" -ifNotExists
