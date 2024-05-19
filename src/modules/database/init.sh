#!/bin/env bash

sudo apt install sqlite3
cat init.sql | sqlite3 shikigami.db
