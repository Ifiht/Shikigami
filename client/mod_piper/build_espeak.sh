#!/bin/bash

cd piper1-gpl
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/local
cmake --build build
cmake --install build
