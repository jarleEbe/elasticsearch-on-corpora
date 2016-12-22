#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re

from xml.etree import ElementTree as ET

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS

def fix_contractions(word, lemma, pos):

#INNIT
      innitW = re.compile("innit", re.IGNORECASE)
      innitL = re.compile("IN N IT")
      innitP = re.compile("VBZ XX0 PNP")

      if re.search(innitW, word) and re.search(innitL, lemma) and re.search(innitP, pos):
            lemma = re.sub(innitL, "INNIT", lemma)
            pos = re.sub(innitP, "VBZ-XX0-PNP", pos)

#DUNNO
      dunnoW = re.compile("dunno", re.IGNORECASE)
      dunnoL = re.compile("DO N NO")
      dunnoP = re.compile("VDB XX0 VVI")

      if re.search(dunnoW, word) and re.search(dunnoL, lemma) and re.search(dunnoP, pos):
            lemma = re.sub(dunnoL, "DUNNO", lemma)
            pos = re.sub(dunnoP, "VDB-XX0-VVI", pos)

#GONNA
      gonnaW = re.compile("gonna", re.IGNORECASE)
      gonnaL = re.compile("GON NA")
      gonnaP = re.compile("VVG TO0")

      if re.search(gonnaW, word) and re.search(gonnaL, lemma) and re.search(gonnaP, pos):
            lemma = re.sub(gonnaL, "GONNA", lemma)
            pos = re.sub(gonnaP, "VVG-TO0", pos)

#WANNA
      wannaW = re.compile("wanna", re.IGNORECASE)
      wannaL = re.compile("WAN NA")
      wannaP = re.compile("VVB TO0")

      if re.search(wannaW, word) and re.search(wannaL, lemma) and re.search(wannaP, pos):
            lemma = re.sub(wannaL, "WANNA", lemma)
            pos = re.sub(wannaP, "VVB-TO0", pos)

      word = re.sub('[.,;:<>$£€¢=!?#_@&%+~/—–‘’“”§¶…`´\"\\{\\}\\[\\]\\(\\)\\*]', '',word)    
      mixed = ''
      wordArr = word.split()
      lemmaArr = lemma.split()
      posArr = pos.split()
      numWord = len(word.split())
      numLemmas = len(lemma.split())
      numPOS = len(pos.split())
      for ind in range(0, numWord - 1):
            mixed = wordArr[ind]
            if ind <= numLemmas:
                  mixed = mixed + ' ' + lemmaArr[ind]
            if ind <= numPOS:
                  mixed = mixed + ' ' + posArr[ind]
      
#      if numWord != numPOS:
#            print(word, end="\n")
#            print(lemma, end="\n")
#            print(pos, end="\n")

#      if numWord != numPOS and numLemmas != numPOS:
#            print(word, end="\n")
#            print(pos, end="\n")

      return lemma, pos, mixed


def segment_text(directory, text):
   local_file = directory + text
   output_directory = directory + 'segmented' + '/'

   output_directory = output_directory.replace("/clean", "")

#   print(local_file)
#   print(output_directory)
#   return
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
      rawtext = re.sub(r'">([\']){1,1}([A-Za-z ]{1,1})', r'"> \1\2', rawtext)
#      rawtext = rawtext.replace(">n't", "> n't")
#      rawtext = rawtext.replace(">N'T", "> N'T")
      rawtext = re.sub(r'<([^>]+?)>', ' ', rawtext)
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
      lemmas = ''
      parts_of_speech = '';
      mixed = ''
      for word in tree:
         wtemp = word.text
         if wtemp:
            wtemp = wtemp.lower()
            if wtemp == ' ':
                  wtemp = 'XXX'
         else:
            wtemp = 'XXX'
         mixed = mixed + wtemp + ' '
         wordforms = wordforms + wtemp + ' '

         myLemma = ''
         myPos = ''

         if word.attrib['lemma']:
               myLemma = word.attrib['lemma']
               if myLemma == ' ':
                     mixed = mixed + 'YYY' + ' '
               else:
                     myLemma = myLemma.upper()
                     lemmas = lemmas + myLemma + ' '
                     mixed = mixed + myLemma + ' '                      
         else:
               mixed = mixed + 'YYY' + ' '

         if word.attrib['pos']:
               myPos = word.attrib['pos']
               if myPos == ' ':
                     mixed = mixed + 'ZZZ' + ' '
               else:
                     myPos = myPos.upper()
                     parts_of_speech = parts_of_speech + myPos + ' '
                     mixed = mixed + myPos + ' '
         else:
               mixed = mixed + 'ZZZ' + ' '
           
      wordforms = re.sub(r' $', '', wordforms)

      lemmas = re.sub(r' $', '', lemmas)
      lemmas = re.sub(r'\s\s+', ' ', lemmas)
      lemmas = lemmas.strip()

      parts_of_speech = re.sub(r' $', '', parts_of_speech)
      parts_of_speech = re.sub(r'\s\s+', ' ', parts_of_speech)
      parts_of_speech = parts_of_speech.strip()

      mixed = re.sub(r' $', '', mixed)
      mixed = re.sub(r'\s\s+', ' ', mixed)
      mixed = mixed.strip()

#      if re.search("dunno", rawtext, re.IGNORECASE) or re.search("gonna", rawtext, re.IGNORECASE) or re.search("wanna", rawtext, re.IGNORECASE) or re.search("innit", rawtext, re.IGNORECASE):
#            lemmas, parts_of_speech, mixed = fix_contractions(rawtext, lemmas, parts_of_speech)
# - 
#      rawtext = re.sub('[.,;:<>$£€¢=!?#_@&%+~/—–‘’“”§¶…`´\"\\{\\}\\[\\]\\(\\)\\*]', '', rawtext)
#      rawtext = re.sub('([.,;:<>!?#_@&~/—–‘’“”§¶…`´\"\\{\\}\\[\\]\\(\\)]+)', '', rawtext)
#      rawtext = re.sub(r'\s\s+', ' ', rawtext)
#      rawtext = re.sub(' -$', '', rawtext)
#      rawtext = re.sub(' - ', ' ', rawtext)
#      rawtext = re.sub('^- ', '', rawtext)
#      rawtext = re.sub(" '$", '', rawtext)
#      rawtext = re.sub("^' ", "", rawtext)
#      rawtext = re.sub(" ' ", " ", rawtext)
#      rawtext = re.sub('^ ', '', rawtext)
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

      new_file.write(lemmas)
      new_file.write("\t")
      new_file.write(parts_of_speech)
      new_file.write("\t")
      new_file.write(mixed)
      new_file.write("\n")

   new_file.close
   
   return


#MAIN

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
      if re.search(xml_files, file): # and re.search(clean_files, file) and not re.search(segmented, dirpath) and not re.search(header, dirpath):
         print (file)
#         print (dirpath)
         return_value = segment_text(dirpath, file)
print ("Segmentation end.")
