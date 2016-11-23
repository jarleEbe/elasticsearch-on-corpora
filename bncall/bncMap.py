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

   setting = {"settings":{"analysis":{"analyzer":{"delimiters_lower":{"type":"pattern","pattern":"(([.,;:\"<>$£+=!?`\{\}\{\}\[\]\*\(\)\?/\\#_@]+)|(\s+))", "lowercase": "true"},"delimiters_upper":{"type":"pattern","pattern":"(([.,;:\"<>$£+=!?`\{\}\{\}\[\]\*\(\)\?/\\#_@]+)|(\s+))", "lowercase": "false"}}}}}

   result = es.indices.create(index=index_name, body=setting)

   return result


def sunit_create_mapping(es, index_name, document_type, field, analyser):

    mapping = {document_type:{"properties":{field:{"type":"string", "store":"yes", "index":"analyzed", "analyzer":analyser, "term_vector":"with_positions_offsets"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result


def create_mapping(es, index_name, document_type, field):

    mapping = {document_type:{"properties":{field:{"type":"string", "store":"yes", "index":"no"}}}}
#    mapping = {document_type:{"properties":{field:{"type":"string", "store":"yes"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result

def integer_create_mapping(es, index_name, document_type, field):

    mapping = {document_type:{"properties":{field:{"type":"integer", "store":"yes"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result

def create_orig_mapping(es, index_name, document_type, field):

    mapping = {document_type:{"properties":{field:{"type":"string", "store":"yes", "index":"no"}}}}
#    mapping = {document_type:{"properties":{field:{"type":"string", "store":"yes"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result


#MAIN
#res = requests.get('http://localhost:9200')
#print(res.content)

#Should be read from command line/URL
myIndex = 'bnces'
myType = 'bncall'

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

created = create_index(es, myIndex)

mapped = sunit_create_mapping(es, myIndex, myType, "rawText", "delimiters_lower")
mapped = sunit_create_mapping(es, myIndex, myType, "lemma", "delimiters_upper")
mapped = sunit_create_mapping(es, myIndex, myType, "pos", "delimiters_upper")
mapped = sunit_create_mapping(es, myIndex, myType, "mixed", "delimiters_upper")

mapped = create_orig_mapping(es, myIndex, myType, "origText")

mapped = create_mapping(es, myIndex, myType, "textId")
mapped = create_mapping(es, myIndex, myType, "sunitId")

mapped = create_mapping(es, myIndex, myType, "domain")
mapped = create_mapping(es, myIndex, myType, "classCode")
mapped = create_mapping(es, myIndex, myType, "catRef")

mapped = integer_create_mapping(es, myIndex, myType, "localId")

#mapped = create_mapping(es, myIndex, myType, "sex")
#mapped = create_mapping(es, myIndex, myType, "birthDate")
#mapped = create_mapping(es, myIndex, myType, "pubPlace")
