#!/usr/bin/python
# -*- coding: utf-8 -*-
# pylint:disable=C0103

from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys
import os
import re
import json
import xmltodict
from elasticsearch import Elasticsearch

from pprint import pprint

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS


def find_decade(year):

    decade = ''

    try:
        intyear = int(year)
    except ValueError:
        print(year, end="\n")
        decade = 'unknown'
        return decade

    if type(intyear) == int:
        if intyear >= 1900 and intyear < 1910:
            decade = '1900'
        elif intyear > 1909 and intyear < 1920:
            decade = '1910'
        elif intyear > 1919 and intyear < 1930:
            decade = '1920'
        elif intyear > 1929 and intyear < 1940:
            decade = '1930'
        elif intyear > 1939 and intyear < 1950:
            decade = '1940'
        elif intyear > 1949 and intyear < 1960:
            decade = '1950'
        elif intyear > 1959 and intyear < 1970:
            decade = '1960'
        elif intyear > 1969 and intyear < 1980:
            decade = '1970'
        elif intyear > 1979 and intyear < 1990:
            decade = '1980'
        elif intyear > 1989 and intyear < 2000:
            decade = '1990'
        elif intyear > 1999 and intyear < 2010:
            decade = '2000'
        elif intyear > 2009 and intyear < 2030:
            decade = '2010'
        elif intyear > 2019 and intyear < 2040:
            decade = '2020'
        else:
            decade = 'unknown'
    else:
        decade = 'unknown'

    return decade


def parse_bnc_header(directory, headerDir, text):

    local_file = directory + text
#    local_file = directory + '/' + text

    local_file = local_file.replace("segmented", headerDir)
#   print(local_file)

   # open the file for reading
    with open(local_file, 'rb') as infile:
        d = xmltodict.parse(infile, xml_attribs=True)

    myJSON = json.dumps(d)
    jsonXML = json.loads(myJSON)

    idNo = ''
    title = ''
    publicationPlace = ''
    publisher = ''
    dateofPublication = ''
    sex = ''
    dateofBirth = ''
    decade = ''
    genre = ''

    if "idno" in myJSON:
        idNo = jsonXML["TEI"]["teiHeader"]["fileDesc"]["publicationStmt"]["idno"]

    if "author" in myJSON:
        author = jsonXML["TEI"]["teiHeader"]["fileDesc"]["sourceDesc"]["biblStruct"]["monogr"]["author"]

    if "monogr" in myJSON:
        title = jsonXML["TEI"]["teiHeader"]["fileDesc"]["sourceDesc"]["biblStruct"]["monogr"]["title"]

    if "pubPlace" in myJSON:
        publicationPlace = jsonXML["TEI"]["teiHeader"]["fileDesc"]["sourceDesc"]["biblStruct"]["monogr"]["imprint"]["pubPlace"]

    if "publisher" in myJSON:
        publisher = jsonXML["TEI"]["teiHeader"]["fileDesc"]["sourceDesc"]["biblStruct"]["monogr"]["imprint"]["publisher"]

    if "imprint" in myJSON:
        dateofPublication = jsonXML["TEI"]["teiHeader"]["fileDesc"]["sourceDesc"]["biblStruct"]["monogr"]["imprint"]["date"]["#text"]

    if "sex" in myJSON:
        sex = jsonXML["TEI"]["teiHeader"]["profileDesc"]["particDesc"]["person"]["sex"]

    if "birth" in myJSON:
        dateofBirth = jsonXML["TEI"]["teiHeader"]["profileDesc"]["particDesc"]["person"]["birth"]["date"]["#text"]

    if "factuality" in myJSON:
        genre = jsonXML["TEI"]["teiHeader"]["profileDesc"]["textDesc"]["factuality"]["#text"]

    myLocalDict = dict()
    myLocalDict['textId'] = idNo
    myLocalDict['author'] = author
    myLocalDict['title'] = title
    myLocalDict['pubDate'] = dateofPublication
    myLocalDict['sex'] = sex
    myLocalDict['genre'] = genre
    myLocalDict['birthDate'] = dateofBirth

    decade = find_decade(dateofPublication)
    myLocalDict['decade'] = decade

    return myLocalDict


def add_data_to_index(es, index_name, document_type, data):

    result = es.index(index=index_name, doc_type=document_type, body=data, request_timeout=30)

#    with open('data.txt', 'w') as outfile:
#        json.dump(data, outfile)
    return result


def split_and_index_text(directory, text, es, esIndex, esType):
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
#            print("Something not right (1): ", end="")
#            print(len(myList), end=" ")
#            print(line, end="\n")
            sunitDict['sunitId'] = myList[0]
            sunitDict['origText'] = ""
            sunitDict['rawText'] = ""
#         sunitDict['lemma'] = ""
#         sunitDict['pos'] = ""
#         sunitDict['mixed'] = ""
            sunitJSON = json.dumps(sunitDict)
            indexed = add_data_to_index(es, esIndex, esType, sunitJSON)
        elif len(myList) >= 2:
#            print("Something not right (2): ", end="")
#            print(len(myList), end=" ")
#            print(line, end="\n")
            sunitDict['sunitId'] = myList[0]
            sunitDict['origText'] = myList[1]
            sunitDict['rawText'] = myList[1]
#         sunitDict['lemma'] = ""
#         sunitDict['pos'] = ""
#         sunitDict['mixed'] = ""
            sunitJSON = json.dumps(sunitDict)
            indexed = add_data_to_index(es, esIndex, esType, sunitJSON)
        else:
            print("Something not right (4): ", end="")
            print(len(myList), end=" ")
            print(line, end="\n")

    return "ok"

# MAIN
if len(sys.argv) <= 1:
    print("Need input directory, e.g. /../../data/ ")
    sys.exit()

datadir = sys.argv[1]

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

txt_files = re.compile(r"\.txt$", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
print ("Indexing ...")
for dirpath, dirs, files in os.walk(datadir):
    for fil in files:
        if re.search(txt_files, fil) and re.search(segmented, dirpath):
            #        print(dirpath)
            print(fil)
            return_value = split_and_index_text(dirpath, fil, es, "cbf", "cbfraw")
