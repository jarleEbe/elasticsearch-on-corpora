#!/usr/bin/python
# -*- coding: utf-8 -*-

#pylint: disable=C0103
#pylint: disable=C0111

from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys
import os
import re
import json
import xmltodict
import pprint

#from xml.etree import ElementTree as ET

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS
def createCounts(totnoTexts, totnoWords, tiaar, tekstene):

    outfile = open("cbf.json", 'w')

    localDict = dict()

    localDict['cbf'] = 'https://nabu.usit.uio.no/hf/ilos/english/cbf/cbf.json'
    localDict['date'] = '2017-01-17'
    localDict['noTexts'] = totnoTexts
    localDict['totnoWords'] = totnoWords
    localDict['Texts'] = tekstene
    localDict['Decades'] = tiaar

    json.dump(localDict, outfile, indent=4)
#    outfile.write('{')
#    for d in localDict:
#        outfile.write(d)
#        outfile.write(str(localDict[d]))

#    outfile.write('}')

    return "ok"

def countrealWords(line):
    words = line.split()
    numwords = 0
    for word in words:
        if re.search(r'^([A-Za-z0-9])', word):
            numwords += 1

    return numwords


def find_decade(year):

    decade = ''

    try:
        intyear = int(year)
    except ValueError:
        print(year, end="\n")
        decade = 'unknown'
        return decade

    if isinstance(intyear, int):
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

    return decade


def parse_bnc_header(directory, headerDir, text):

    local_file = directory + text
#    local_file = directory + '/' + text

    local_file = local_file.replace("clean", headerDir)
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

    if "idno" in myJSON:
        idNo = jsonXML["TEI"]["teiHeader"][
            "fileDesc"]["publicationStmt"]["idno"]

    if "author" in myJSON:
        author = jsonXML["TEI"]["teiHeader"]["fileDesc"][
            "sourceDesc"]["biblStruct"]["monogr"]["author"]

    if "monogr" in myJSON:
        title = jsonXML["TEI"]["teiHeader"]["fileDesc"][
            "sourceDesc"]["biblStruct"]["monogr"]["title"]

    if "pubPlace" in myJSON:
        publicationPlace = jsonXML["TEI"]["teiHeader"]["fileDesc"][
            "sourceDesc"]["biblStruct"]["monogr"]["imprint"]["pubPlace"]

    if "publisher" in myJSON:
        publisher = jsonXML["TEI"]["teiHeader"]["fileDesc"][
            "sourceDesc"]["biblStruct"]["monogr"]["imprint"]["publisher"]

    if "imprint" in myJSON:
        dateofPublication = jsonXML["TEI"]["teiHeader"]["fileDesc"][
            "sourceDesc"]["biblStruct"]["monogr"]["imprint"]["date"]["#text"]

    if "sex" in myJSON:
        sex = jsonXML["TEI"]["teiHeader"][
            "profileDesc"]["particDesc"]["person"]["sex"]

    if "birth" in myJSON:
        dateofBirth = jsonXML["TEI"]["teiHeader"]["profileDesc"][
            "particDesc"]["person"]["birth"]["date"]["#text"]

    myLocalDict = dict()
    myLocalDict['textId'] = idNo
    myLocalDict['author'] = author
    myLocalDict['title'] = title
    myLocalDict['pubDate'] = dateofPublication
    myLocalDict['sex'] = sex
    myLocalDict['birthDate'] = dateofBirth

    decade = find_decade(dateofPublication)
    if decade == '':
        print("Cannot find decade")
        print(str(myLocalDict['textId']))
    myLocalDict['decade'] = decade

    return myLocalDict


def segment_text(directory, text):
    local_file = directory + text
    output_directory = directory + 'segmented' + '/'

    output_directory = output_directory.replace("/clean", "")

    textid = text
    textid = textid.replace("_clean.txt", "_header.xml")
    sunitDict = dict()
    sunitDict = parse_bnc_header(directory, "header", textid)
    decade = sunitDict['decade']

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
    numberofWords = 0
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
        numberofWords = numberofWords + countrealWords(line)

    new_file.close

    return numberofWords, decade


# MAIN

if len(sys.argv) < 1:
    print("Need input directory")
    sys.exit()

mystartdir = sys.argv[1]

txt_files = re.compile(r"\.txt$", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
tiaar = dict()
texts = dict()
print ("Start segmenting ...")
totwords = 0
totfiles = 0
for dirpath, dirs, files in os.walk(mystartdir):
    for fil in files:
        if re.search(txt_files, fil):
#            print (fil)
#         print (dirpath)
            totfiles += 1
            return_value = segment_text(dirpath, fil)
            textCode = fil
            textCode = textCode.replace("_clean.txt", "")
            nowords = int(return_value[0])
            tiaaret = str(return_value[1])
            texts[textCode] = nowords
            if tiaaret in tiaar:
                nowordsintiaar = int(tiaar[tiaaret])
                nowordsintiaar = nowordsintiaar + nowords
                tiaar[tiaaret] = int(nowordsintiaar)
            else:
                tiaar[tiaaret] = int(nowords)
#            print(str(return_value[0]))
#            print(str(return_value[1]))
            totwords = totwords + nowords
finished = createCounts(totfiles, totwords, tiaar, texts)
#json_string = json.dumps(tiaar, indent=3)
#print(json_string)
#json_string = json.dumps(texts, indent=3)
#print(json_string)
#print ("Segmentation end.")
print("Total number of words: ")
print(str(totwords))
print("Total number of texts: ")
print(str(totfiles))
