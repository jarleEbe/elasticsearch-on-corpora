#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re, json, xmltodict
from elasticsearch import Elasticsearch

from pprint import pprint

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

   return myLocalDict


def add_data_to_index(es, index_name, document_type, data):

    result = es.index(index=index_name, doc_type=document_type, body=data, request_timeout=30)
    return result

def split_and_index_text(directory, text, es, esIndex, esType ):
   local_file = directory + '/' + text

   # open the file for reading
   with open(local_file, 'r') as infile:
      content = infile.readlines() 

   textid = text
   textid = textid.replace("_seg.txt", "")
   header_file_name = textid + '_header.xml'

   sunitDict = dict()
   sunitDict = parse_bnc_header(directory, "header", header_file_name)

   lid = 0
   for line in content:
      line = line.strip()
      myList = line.split("\t")
      lid += 1
      sunitDict['localId'] = lid
#      print(myList[0])
      if len(myList) < 1:
         print("Something not right (1): ", end="")
         print(len(myList), end=" ")
         print(line, end="\n")
         sunitDict['sunitId'] = myList[0]
         sunitDict['origText'] = ""
         sunitDict['rawText'] = ""
         sunitDict['lemma'] = ""
         sunitDict['pos'] = ""
         sunitDict['mixed'] = ""
         sunitJSON = json.dumps(sunitDict)
         indexed = add_data_to_index(es, esIndex, esType, sunitJSON)
      elif len(myList) <= 2:
         print("Something not right (2): ", end="")
         print(len(myList), end=" ")
         print(line, end="\n")
         sunitDict['sunitId'] = myList[0]
         sunitDict['origText'] = myList[1]
         sunitDict['rawText'] = ""
         sunitDict['lemma'] = ""
         sunitDict['pos'] = ""
         sunitDict['mixed'] = ""
         sunitJSON = json.dumps(sunitDict)
         indexed = add_data_to_index(es, esIndex, esType, sunitJSON)
      elif len(myList) < 6:
         print("Something not right (3): ", end="")
         print(len(myList), end=" ")
         print(line, end="\n")
         sunitDict['sunitId'] = myList[0]
         sunitDict['origText'] = myList[1]
         sunitDict['rawText'] = myList[2]
         sunitDict['lemma'] = ""
         sunitDict['pos'] = ""
         sunitDict['mixed'] = ""
         sunitJSON = json.dumps(sunitDict)
         indexed = add_data_to_index(es, esIndex, esType, sunitJSON)
      elif len(myList) >= 6:
         sunitDict['sunitId'] = myList[0]
         sunitDict['origText'] = myList[1]
         sunitDict['rawText'] = myList[2]
         sunitDict['lemma'] = myList[3]
         sunitDict['pos'] = myList[4]
         sunitDict['mixed'] = myList[5]
#         pprint(sunitDict)
         sunitJSON = json.dumps(sunitDict)
#         pprint(sunitJSON)
         indexed = add_data_to_index(es, esIndex, esType, sunitJSON)
      else:
         print("Something not right (4): ", end="")
         print(len(myList), end=" ")
         print(line, end="\n")

   return "ok"

#MAIN
#res = requests.get('http://localhost:9200')
#print(res.content)

if len(sys.argv) <= 1:
    print("Need input directory, e.g. /../../data/ ")
    sys.exit()

datadir = sys.argv[1]

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

txt_files = re.compile("\.txt", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
print ("Indexing ...")
for dirpath, dirs, files in os.walk(datadir):
   for file in files:
      if re.search(txt_files, file) and re.search(segmented, dirpath):
#         print(dirpath)
         print(file)
         return_value = split_and_index_text(dirpath, file, es, "bnces", "bncall")
