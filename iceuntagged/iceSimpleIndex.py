#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re, requests, json
from elasticsearch import Elasticsearch

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS

def add_data_to_index(es, index_name, document_type, data):

    result = es.index(index=index_name, doc_type=document_type, body=data, request_timeout=30)

    return result

def split_and_index_text(es, theIndex, theType, text, code, region, lid):
   local_file = text

   # open the file for reading
   with open(local_file, 'r',) as infile:
      content = infile.read() 

   sunitDict = dict()
   lines = re.split("\n", content)
   for line in lines:
      line = line.strip()
#      print(line)
      myList = line.split("\t")
      if len(myList) >= 2:
          lid += 1
          sunitDict['localId'] = lid
          sunitDict['areaCode'] = code
          sunitDict['region'] = region
          sunitDict['rawText'] = myList[1]
          tempid = myList[0]
          sunitDict['sunitId'] = tempid
          myNewList = tempid.split(":")
          if len(myNewList) > 1:
              sunitDict['textId'] = myNewList[0] + ':' + myNewList[1]
              tType = myNewList[1]
              if re.match("S", tType):
                  sunitDict['textType'] = "spoken"
              elif re.match("W", tType):
                  sunitDict['textType'] = "written"
              else:
                  sunitDict['textType'] = "unknown"
          else:
              print("Cannot generate textId/textType -- Empty line?", end="")
              print(tempid, end="\n")
              sunitDict['textId'] = tempid
          sunitJSON = json.dumps(sunitDict)
#          print(sunitJSON)
          indexed = add_data_to_index(es, theIndex, theType, sunitJSON)
      elif len(myList) >= 1:
          lid += 1
          sunitDict['localId'] = lid
          sunitDict['areaCode'] = code
          sunitDict['region'] = region
          sunitDict['rawText'] = ""
          tempid = myList[0]
          sunitDict['sunitId'] = tempid
          myNewList = tempid.split(":")
          if len(myNewList) > 1:
              sunitDict['textId'] = myNewList[0] + ':' + myNewList[1]
              tType = myNewList[1]
              if re.match("s", tType):
                  sunitDict['textType'] = "spoken"
              elif re.match("w", tType):
                  sunitDict['textType'] = "written"
              else:
                  sunitDict['textType'] = "unknown"
          else:
              print("Cannot generate textId/textType -- Empty line?", end="")
              print(tempid, end="\n")
              sunitDict['textId'] = tempid
          sunitJSON = json.dumps(sunitDict)
#          print(sunitJSON)
          indexed = add_data_to_index(es, theIndex, theType, sunitJSON)
      else:
          print("Cannot index:", end="")
          print(line, end="\n")

   return lid

#MAIN
#res = requests.get('http://localhost:9200')
#print(res.content)

#Should/Could be read from command line/URL
myIndex = 'ice'
myType = 'iceraw'

if len(sys.argv) < 4:
    print("Need input file (e.g. 'ice-gb.txt'), country/area code (e.g. 'aus', 'can', 'gbr', 'sgp'), region (e.g. 'north', 'south' or 'other') and start id (a number).")
    sys.exit()

mytext = sys.argv[1]
myarea = sys.argv[2]
myregion = sys.argv[3]
mylocalid = sys.argv[4]

print(mytext)
print(myarea)
print(myregion)
print(mylocalid)

localidint = int(mylocalid)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

return_value = split_and_index_text(es, myIndex, myType, mytext, myarea, myregion, localidint)

print("Local id :", end="")
print(return_value)
