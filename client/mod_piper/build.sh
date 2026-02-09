#!/bin/bash

clang++ piper-serve.c \
  -std=c++11 \
  -I./piper1-gpl/local/include \
  -L./piper1-gpl/local \
  -L./piper1-gpl/local/lib \
  -lpiper -lonnxruntime \
  -Wl,-rpath,./piper1-gpl/local \
  -Wl,-rpath,./piper1-gpl/local/lib \
  -o hamelin