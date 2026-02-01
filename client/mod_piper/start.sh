$!/bin/bash

python -m piper -m en_GB-cori-high --output_raw -- $1 | ffplay -nodisp -autoexit -f s16le -ar 22050 -ch_layout mono -