#!/usr/bin/python

# if we want to give our script parameters, we need a special library
import sys, os, re, json, xmltodict

from xml.etree import ElementTree
#from elasticsearch import Elasticsearch

# FUNCTIONS

#def add_data_to_index(es, index_name, document_type, data):

#    result = es.index(index=index_name, doc_type=document_type, body=data)

#    return result

def parse_bnc_header(directory, text):
   local_file = directory + '/' + text

   # open the file for reading
   with open(local_file, 'rb') as infile:
       d = xmltodict.parse(infile, xml_attribs=True)

   myJSON = json.dumps(d)

   jsonXML = json.loads(myJSON)

   idNo_text = jsonXML["teiHeader"]["fileDesc"]["publicationStmt"]["idno"][0]["#text"]
   idNo_type = jsonXML["teiHeader"]["fileDesc"]["publicationStmt"]["idno"][0]["@type"]
   title = jsonXML["teiHeader"]["fileDesc"]["titleStmt"]["title"]
   classCode = jsonXML["teiHeader"]["profileDesc"]["textClass"]["classCode"]["#text"]
   catRef = jsonXML["teiHeader"]["profileDesc"]["textClass"]["catRef"]["@targets"]

   print(idNo_text)
#   print(idNo_type)
   domain = ''
   if re.search("domain:", title):
       domain = re.sub(r'^(.*)\(domain:', '', title)
       domain = re.sub(r'^ ', '', domain)
       domain = re.sub(r'\)$', '', domain)
       domain = re.sub(r'\s+ $', '', domain)
   else:
       domain = 'unknown'
   print(domain)
   print(classCode)
   print(catRef)

   return "ok"

#MAIN

xml_files = re.compile("\.xml", flags=re.IGNORECASE)
header_dir = re.compile("header", flags=re.IGNORECASE)
print ("Start...")
for dirpath, dirs, files in os.walk("."):
#   print (dirpath)
#   print (dirs)
   for file in files:
      if re.search(xml_files, file) and re.search(header_dir, dirpath):
         print(file)
         return_value = parse_bnc_header(dirpath, file)
