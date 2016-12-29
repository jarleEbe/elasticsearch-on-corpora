#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys
import os
import re

#from xml.etree import ElementTree as ET

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS


def segment_text(directory, text):
    local_file = directory + text
    output_directory = directory + 'segmented' + '/'

    output_directory = output_directory.replace("/clean", "")
    # Generate output file (new_file)
    outfile = text
    outfile = outfile.replace("_clean.txt", "_seg.txt")
    outfile = output_directory + outfile
    new_file = open(outfile, 'w')

    # open the file for reading
    with open(local_file, 'r') as infile:
        content = infile.readlines()

    textId = text
    textId = text.replace("_clean.txt", "")
    localid = 0
    for line in content:
        line = line.strip()
        localid += 1
        line = re.sub(r'<([^>]+?)>', '', line)
        line = line.strip()
        new_file.write(textId)
        new_file.write(".s")
        new_file.write(str(localid))
        new_file.write("\t")
        new_file.write(line)
        new_file.write("\n")

    new_file.close

    return


# MAIN

if len(sys.argv) < 1:
    print("Need input directory")
    sys.exit()

mystartdir = sys.argv[1]

txt_files = re.compile("\.txt$", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)

print ("Start segmenting ...")
for dirpath, dirs, files in os.walk(mystartdir):
    for file in files:
        if re.search(txt_files, file):
            print (file)
#         print (dirpath)
            return_value = segment_text(dirpath, file)
print ("Segmentation end.")
