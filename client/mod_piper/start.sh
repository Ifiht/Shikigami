#!/bin/bash

# python -m piper -m en_GB-cori-high --output_raw -- $1 | ffplay -nodisp -autoexit -f s16le -ar 22050 -ch_layout mono -

./hamelin \
  ./voices/cori_en_gb/en_GB-cori-high.onnx \
  ./voices/cori_en_gb/en_GB-cori-high.onnx.json \
  ./piper1-gpl/local/espeak-ng-data \
  "Good morning." | ffplay -nodisp -autoexit -f s16le -ar 22050 -ch_layout mono -
