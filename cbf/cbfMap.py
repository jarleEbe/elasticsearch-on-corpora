#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, requests, json
from elasticsearch import Elasticsearch

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS

def create_index(es, index_name):

   settingsfile = 'analyzer-settings.json'
   mySetting = ''
   with open(settingsfile, 'r') as infile:
      mySetting = infile.read()

   result = es.indices.create(index=index_name, body=mySetting)

   return result


def sunit_create_mapping(es, index_name, document_type, field, analyser):

    mapping = {document_type:{"properties":{field:{"type":"text", "store":"yes", "index":"analyzed", "analyzer":analyser, "term_vector":"with_positions_offsets"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result


def create_mapping(es, index_name, document_type, field):

    mapping = {document_type:{"properties":{field:{"type":"keyword", "store":"yes", "index":"no"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result

def integer_create_mapping(es, index_name, document_type, field):

    mapping = {document_type:{"properties":{field:{"type":"integer", "store":"yes"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result

def create_orig_mapping(es, index_name, document_type, field):

    mapping = {document_type:{"properties":{field:{"type":"text", "store":"yes", "index":"no"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result


#MAIN
#res = requests.get('http://localhost:9200')
#print(res.content)

#Should be read from command line/URL
myIndex = 'cbf'
myType = 'cbfraw'

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

created = create_index(es, myIndex)

mapped = sunit_create_mapping(es, myIndex, myType, "rawText", "delimiters_lower")
#mapped = sunit_create_mapping(es, myIndex, myType, "lemma", "delimiters_upper")
#mapped = sunit_create_mapping(es, myIndex, myType, "pos", "delimiters_upper")
#mapped = sunit_create_mapping(es, myIndex, myType, "mixed", "delimiters_upper")

mapped = create_orig_mapping(es, myIndex, myType, "origText")

mapped = create_mapping(es, myIndex, myType, "textId")
mapped = create_mapping(es, myIndex, myType, "sunitId")

#mapped = create_mapping(es, myIndex, myType, "domain")
#mapped = create_mapping(es, myIndex, myType, "classCode")
#mapped = create_mapping(es, myIndex, myType, "catRef")

mapped = integer_create_mapping(es, myIndex, myType, "localId")

mapped = create_mapping(es, myIndex, myType, "author")
mapped = create_mapping(es, myIndex, myType, "title")
mapped = create_mapping(es, myIndex, myType, "pubDate")
mapped = create_mapping(es, myIndex, myType, "sex")
mapped = create_mapping(es, myIndex, myType, "birthDate")
mapped = create_mapping(es, myIndex, myType, "pubPlace")
mapped = create_mapping(es, myIndex, myType, "decade")
