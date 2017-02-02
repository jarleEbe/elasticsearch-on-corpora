#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import sys, os, re
from xml.etree import ElementTree as ET

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS

def segment_text(directory, text):
    local_file = directory + text
    output_directory = directory + 'segmented' + '/'

    output_directory = output_directory.replace("/clean", "")

    # Generate output file (new_file)
    outfile = text
    outfile = outfile.replace(".xml", "_seg.txt")
    outfile = output_directory + outfile
    new_file = open(outfile, 'w')

    # open the file for reading
    with open(local_file, 'r') as infile:
        content = infile.readlines()

    textId = text
    textId = text.replace(".xml", "")
    rawtext = ''
    for line in content:
        line = line.strip()
        tree = ET.fromstring(line)
        sunitId = textId + '.s' + tree.attrib['n']
        new_file.write(sunitId)
        new_file.write("\t")
        rawtext = line
        new_file.write(rawtext)
        new_file.write("\t")
        rawtext = re.sub(r'">([\']{1,1})([A-Za-z ]{1,1})', r'"> \1\2', rawtext)
        rawtext = re.sub(r'<([^>]+?)>', ' ', rawtext)
        rawtext = rawtext.replace('&amp;', '&')
        rawtext = re.sub(r'\s\s+', ' ', rawtext)
        rawtext = re.sub(r' ,', ',', rawtext)
        rawtext = re.sub(r' \.', '.', rawtext)
        rawtext = re.sub(r' \?', '?', rawtext)
        rawtext = re.sub(r' ;', ';', rawtext)
        rawtext = re.sub(r' \!', '!', rawtext)
        rawtext = re.sub(r' :', ':', rawtext)
        rawtext = rawtext.strip()
        new_file.write(rawtext)
        new_file.write("\t")
        wordforms = ''
        rawwords = ''
        lemmas = ''
        parts_of_speech = ''
        mixed = ''
        wraw = ''
        wtemp = ''
        for word in tree:
            wtemp = word.text
            wraw = wtemp
#            print(wraw, end="\n")
            if wraw:
                wraw = wraw.strip()
                if wraw == '':
                    wraw = 'XXX'
            else:
                wraw = 'XXX'
#            rest = word.tail
#            if rest:
#                print(rest, end="\n")
            if wtemp:
                wtemp = wtemp.lower()
                if wtemp == ' ':
                    wtemp = 'XXX'
            else:
                wtemp = 'XXX'
            if re.search(' ', wraw):
                print('Wordform with blank: ')
                print(wraw, end="\n")
            mixed = mixed + wtemp + ' '
            wordforms = wordforms + wraw + ' '

            myLemma = ''
            myPos = ''

            if word.attrib['lemma']:
                myLemma = word.attrib['lemma']
                if myLemma == ' ':
                    myLemma = 'YYY'
                else:
                    myLemma = myLemma.upper()
            else:
                myLemma = 'YYY'
            lemmas = lemmas + myLemma + ' '
            mixed = mixed + myLemma + ' '

            if word.attrib['pos']:
                myPos = word.attrib['pos']
                if myPos == ' ':
                    myPos = 'ZZZ'
                else:
                    myPos = myPos.upper()
            else:
                myPos = 'ZZZ'
            parts_of_speech = parts_of_speech + myPos + ' '
            mixed = mixed + myPos + ' '

        wordforms = re.sub(r'\&amp;', '\&', wordforms)
        wordforms = re.sub(r' $', '', wordforms)
        wordforms = re.sub(r'\s\s+', ' ', wordforms)
        wordforms = wordforms.strip()

        lemmas = re.sub(r' $', '', lemmas)
        lemmas = re.sub(r'\s\s+', ' ', lemmas)
        lemmas = lemmas.strip()

        parts_of_speech = re.sub(r' $', '', parts_of_speech)
        parts_of_speech = re.sub(r'\s\s+', ' ', parts_of_speech)
        parts_of_speech = parts_of_speech.strip()

        mixed = re.sub(r'\&amp;', '\&', mixed)
        mixed = re.sub(r' $', '', mixed)
        mixed = re.sub(r'\s\s+', ' ', mixed)
        mixed = mixed.strip()

        numWord = len(wordforms.split())
        numLemmas = len(lemmas.split())
        numPOS = len(parts_of_speech.split())
        if numWord != numLemmas:
            print(wordforms, end="\n")
            print(lemmas, end="\n")
            print(parts_of_speech, end="\n")

        if numWord != numPOS and numLemmas != numPOS:
            print(wordforms, end="\n")
            print(parts_of_speech, end="\n")

        new_file.write(wordforms)
        new_file.write("\t")
        new_file.write(lemmas)
        new_file.write("\t")
        new_file.write(parts_of_speech)
        new_file.write("\t")
        new_file.write(mixed)
        new_file.write("\n")

    new_file.close

    return


# MAIN

if len(sys.argv) < 1:
    print("Need input directory")
    sys.exit()

mystartdir = sys.argv[1]

xml_files = re.compile("\.xml$", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)

print ("Start segmenting ...")
for dirpath, dirs, files in os.walk(mystartdir):
    #   print (dirpath)
    #   print (dirs)
    for file in files:
        # and re.search(clean_files, file) and not re.search(segmented,
        # dirpath) and not re.search(header, dirpath):
        if re.search(xml_files, file):
            print (file)
#         print (dirpath)
            return_value = segment_text(dirpath, file)
print ("Segmentation end.")
