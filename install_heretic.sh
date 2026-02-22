#!/bin/bash

conda create --name heretic python=3.12
conda activate heretic
pip3 install torch torchvision
pip install -U heretic-llm