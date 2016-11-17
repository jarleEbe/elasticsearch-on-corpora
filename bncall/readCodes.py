#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re, json, xmltodict
from elasticsearch import Elasticsearch

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS
def parse_bnc_header(directory, headerDir, text):

   local_file = directory + '/' + text

   local_file = local_file.replace("segmented", headerDir)
#   print(local_file)

   # open the file for reading
   with open(local_file, 'rb') as infile:
       d = xmltodict.parse(infile, xml_attribs=True)

   myJSON = json.dumps(d)
   jsonXML = json.loads(myJSON)

   idNo_text = ''
   idNo_type = ''
   title = ''
   classCode = ''
   catRef = ''

   idNo_text = jsonXML["teiHeader"]["fileDesc"]["publicationStmt"]["idno"][0]["#text"]
   idNo_type = jsonXML["teiHeader"]["fileDesc"]["publicationStmt"]["idno"][0]["@type"]
   title = jsonXML["teiHeader"]["fileDesc"]["titleStmt"]["title"]
   classCode = jsonXML["teiHeader"]["profileDesc"]["textClass"]["classCode"]["#text"]
   catRef = jsonXML["teiHeader"]["profileDesc"]["textClass"]["catRef"]["@targets"]

   domain = ''
   if re.search("domain:", title):
       domain = re.sub(r'^(.*)\(domain:', '', title)
       domain = re.sub(r'^ ', '', domain)
       domain = re.sub(r'\)$', '', domain)
       domain = re.sub(r'\s+ $', '', domain)
   else:
       domain = 'unknown'

   myLocalDict = dict()
   myLocalDict['textId'] = idNo_text
   myLocalDict['domain'] = domain
   myLocalDict['classCode'] = classCode
   myLocalDict['catRef'] = catRef

   print(domain)
   print(classCode)
   print(catRef)

   return myLocalDict


def split_and_index_text(directory, text):
   local_file = directory + '/' + text

   # open the file for reading
   with open(local_file, 'r') as infile:
      content = infile.readlines() 

   textid = text
   textid = textid.replace("_seg.txt", "")
   header_file_name = textid + '_header.xml'

   sunitDict = dict()
   sunitDict = parse_bnc_header(directory, "header", header_file_name)


   return "ok"

#MAIN

if len(sys.argv) <= 1:
    print("Need input directory, e.g. /../../data/ ")
    sys.exit()

datadir = sys.argv[1]

txt_files = re.compile("\.txt", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
#print ("Indexing ...")
for dirpath, dirs, files in os.walk(datadir):
   for file in files:
      if re.search(txt_files, file) and re.search(segmented, dirpath):
#         print(dirpath)
#         print(file)
         return_value = split_and_index_text(dirpath, file)
