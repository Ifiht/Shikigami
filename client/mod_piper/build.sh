#!/bin/bash

clang++ piper-serve.cpp \
  -std=c++11 \
  -I./piper1-gpl/local/include \
  -I./beanstalk-client \
  ./piper1-gpl/local/libpiper.a \
  ./piper1-gpl/build/espeak_ng-install/lib/libespeak-ng.a \
  ./piper1-gpl/build/espeak_ng/src/espeak_ng_external-build/src/ucd-tools/libucd.a \
  ./beanstalk-client/libbeanstalk.a \
  -L./piper1-gpl/local/lib \
  -lonnxruntime \
  -Wl,-rpath,@executable_path/piper1-gpl/local/lib \
  -o hamelin