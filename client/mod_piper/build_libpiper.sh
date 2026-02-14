#!/bin/bash

cd piper1-gpl/libpiper

# Modify CMakeLists.txt to build STATIC instead of SHARED
sed -i.bak 's/add_library(piper SHARED/add_library(piper STATIC/' CMakeLists.txt

# Rebuild with static library
rm -rf build
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/../local
cmake --build build
cmake --install build

# Restore original CMakeLists.txt
mv CMakeLists.txt.bak CMakeLists.txt