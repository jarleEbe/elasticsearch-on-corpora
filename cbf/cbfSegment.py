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
import datetime

#from xml.etree import ElementTree as ET

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS
def createCounts(totnoTexts, totnoWords, tiaar, tekstene, male, female, genres):

    outfile = open("cbf.json", 'w')

    now = datetime.datetime.now()
    date = now.strftime("%Y-%m-%d")
    localDict = dict()

    localDict = json.loads(tekstene)
    localDict['cbf'] = 'https://nabu.usit.uio.no/hf/ilos/english/cbf/cbf.json'
    localDict['date'] = date
    localDict['noTexts'] = totnoTexts
    localDict['male'] = male
    localDict['female'] = female
    localDict['totnoWords'] = totnoWords
#    localDict['Texts'] = tekstene
    localDict['Decades'] = tiaar
    localDict['Genres'] = genres
    json.dump(localDict, outfile, indent=4)

    decadesfile = open("cbfdecades.csv", "w")
    for aar in sorted(tiaar):
        decadesfile.write(aar)
        decadesfile.write(",")
        temp = str(tiaar[aar])
        decadesfile.write(temp)
        decadesfile.write("\n")

#    outfile.write('}')

    return "ok"

def countrealWords(line):
    words = line.split()
    numwords = 0
    for word in words:
#        if re.search(r'^([A-Za-z0-9])', word):
#        if re.search(r"(^[A-Za-z0-9'])", word):
        if re.match(r"([A-Za-z0-9'])", word):
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

    filename = text
    filename = filename.replace("_header.xml", "")

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

    sex = sex.strip()
    if sex != 'male' and sex != 'female':
        print('Wrong sex:', end="")
        print(sex, end=", ")
        print(idNo, end="\n")

    if idNo != filename:
        print('Id and filename do not match: ', end="")
        print(idNo, end=" <> ")
        print(filename, end="\n")

    myLocalDict = dict()
    myLocalDict['textId'] = idNo
    myLocalDict['author'] = author
    myLocalDict['title'] = title
    myLocalDict['pubDate'] = dateofPublication
    myLocalDict['sex'] = sex
    myLocalDict['genre'] = genre
    myLocalDict['birthDate'] = dateofBirth

    decade = find_decade(dateofPublication)
    if decade == '' or decade == 'unknown':
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
    sex = sunitDict['sex']
    genre = sunitDict['genre']

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
        if line:
            line = re.sub(r'<([^>]+?)>', '', line)
            line = line.strip()
            if line:
                localid += 1
                new_file.write(textId)
                new_file.write(".s")
                new_file.write(str(localid))
                new_file.write("\t")
                new_file.write(line)
                new_file.write("\n")
                numberofWords = numberofWords + countrealWords(line)

    new_file.close()

    return numberofWords, decade, sex, genre


# MAIN

if len(sys.argv) < 1:
    print("Need input directory")
    sys.exit()

mystartdir = sys.argv[1]

txt_files = re.compile(r"\.txt$", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
tiaar = dict()
texts = dict()
newtext = dict()
genres = dict()
jsontextstring = ''
print ("Start segmenting ...")
totwords = 0
totfiles = 0
maleorfemale = ''
genre = ''
totnumberofmale = 0
totnumberoffemale = 0
totnumberofunknown = 0
for dirpath, dirs, files in os.walk(mystartdir):
    for fil in files:
        if re.search(txt_files, fil):
            print (fil)
#         print (dirpath)
            totfiles += 1
            return_value = segment_text(dirpath, fil)
            textCode = fil
            textCode = textCode.replace("_clean.txt", "")
            nowords = int(return_value[0])
            tiaaret = str(return_value[1])
            maleorfemale = str(return_value[2])
            genre = str(return_value[3])
            texts[textCode] = nowords #Not in use
            jsontextstring += '"' + textCode + '": {' + '"noWords" :' + str(nowords) + ', "Gender":' + '"' + maleorfemale + '",' + '"Genre":' + '"' + genre + '",' + '"Decade":' + '"' + tiaaret + '"},'
#            print(jsontextstring)
#            jsontextstring += '"' + textCode + '": {' + '"noWords" :' + str(nowords) + ', "Gender":' + '"' + maleorfemale + '",' + '"Decade":' + '"' + tiaaret + '"},'
#            jsontextstring += '"' + textCode + '": {' + '"noWords" :' + str(nowords) + ', "Gender":' + '"' + maleorfemale + '",' + ', "Genre":' + '"' + genre + '"' + ', "Decade":' + '"' + tiaaret + '"},'
            if tiaaret in tiaar:
                nowordsintiaar = int(tiaar[tiaaret])
                nowordsintiaar = nowordsintiaar + nowords
                tiaar[tiaaret] = int(nowordsintiaar)
            else:
                tiaar[tiaaret] = int(nowords)

            if genre in genres:
                nowordsingenre = int(genres[genre])
                nowordsingenre = nowordsingenre + nowords
                genres[genre] = int(nowordsingenre)
            else:
                genres[genre] = int(nowords)

            if maleorfemale == 'male':
                totnumberofmale = totnumberofmale + nowords
            elif maleorfemale == 'female':
                totnumberoffemale = totnumberoffemale + nowords
            else:
                totnumberofuknown = totnumberofunknown + nowords
#            print(str(return_value[0]))
#            print(str(return_value[1]))
#            print(str(return_value[2]))
#            print(str(return_value[3]))
            totwords = totwords + nowords
jsontextstring = jsontextstring[:-1]
jsontextstring = '{"Texts": {' + jsontextstring + '}}'
finished = createCounts(totfiles, totwords, tiaar, jsontextstring, totnumberofmale, totnumberoffemale, genres)
#json_string = json.dumps(tiaar, indent=3)
#print(json_string)
#json_string = json.dumps(texts, indent=3)
#print(json_string)
#print ("Segmentation end.")
print("Total number of words: ")
print(str(totwords))
print("Total number of texts: ")
print(str(totfiles))
print("Number of unknown sex:")
print(str(totnumberofunknown))
