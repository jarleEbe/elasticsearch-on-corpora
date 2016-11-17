#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re

from xml.etree import ElementTree as ET

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS

def segment_text(directory, text):
   local_file = directory + '/' + text
   output_directory = 'segmented' + '/'

   # Generate output file (new_file)
   outfile = text
   outfile = outfile.replace(".xml", "_seg.txt")
   outfile = output_directory + outfile
#   new_file = codecs.open(outfile, 'w', encoding="utf-8")
   new_file = open(outfile, 'w')

   # open the file for reading
   with open(local_file, 'r') as infile:
      content = infile.readlines() 

   textId = text
   textId = text.replace(".xml", "")
   for line in content:
      line = line.strip()
#      print (line, end="\n")
#      print("\n")
      tree = ET.fromstring(line)
      sunitId = textId + '.s' + tree.attrib['n']
      new_file.write(sunitId)
      new_file.write("\t")
      rawtext = line
      new_file.write(rawtext)
      new_file.write("\t")
      rawtext = re.sub(r'<([^>]+?)>', '', rawtext)
      new_file.write(rawtext)
      new_file.write("\t")
      lemmas = ''
      parts_of_speech = '';
      mixed = ''
      for word in tree:
         wtemp = word.text
         if wtemp:
            wtemp = wtemp.lower()
         else:
            wtemp = ''
         mixed = mixed + wtemp + ' '

         myLemma = word.get('lemma', 'YYY')
         myPos = word.get('pos', 'ZZZ')

         if myLemma == 'YYY':
            mixed = mixed + myLemma + ' '
         else:
            temp = word.attrib['lemma']
            temp = temp.upper()
            lemmas = lemmas + temp + ' '
            mixed = mixed + temp + ' '

         if myPos == 'ZZZ':
            mixed = mixed + myPos + ' '
         else:
            temp = word.attrib['pos']
            temp = temp.upper()
            parts_of_speech = parts_of_speech + temp + ' '
            mixed = mixed + temp + ' '
            
      lemmas = re.sub(r' $', '', lemmas)
      parts_of_speech = re.sub(r' $', '', parts_of_speech)
      mixed = re.sub(r' $', '', mixed)
      mixed = re.sub(r'\s+', ' ', mixed)

      new_file.write(lemmas)
      new_file.write("\t")
      new_file.write(parts_of_speech)
      new_file.write("\t")
      new_file.write(mixed)
      new_file.write("\n")

   new_file.close
   
   return


#MAIN
xml_files = re.compile("\.xml$", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)

print ("Start ...")
for dirpath, dirs, files in os.walk("clean/"):
#   print (dirpath)
#   print (dirs)
   for file in files:
      if re.search(xml_files, file): # and re.search(clean_files, file) and not re.search(segmented, dirpath) and not re.search(header, dirpath):
         print (file)
#         print (dirpath)
         return_value = segment_text(dirpath, file)
print ("End.")
