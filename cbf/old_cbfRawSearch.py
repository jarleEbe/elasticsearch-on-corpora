#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys
import os
import re
import codecs
import requests
import json

from elasticsearch import Elasticsearch

reload(sys)
sys.setdefaultencoding("utf-8")

UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

# FUNCTIONS


def get_filters(filters):

    print(filters)

    myFilterDict = dict()

    myfilters = list()
    if re.search(" ", filters):
        myfilters = filters.split(" ")
    else:
        myfilters.append(filters)

    key = ''
    value = ''
    filters_exist = False
    if len(myfilters) > 1:
        print("Complex filter")
        for row in myfilters:
            myonefilter = list()
            if re.search("=", row):
                myonefilter = row.split("=")
                key = myonefilter[0]
                value = myonefilter[1]
                myFilterDict[key] = value
                filters_exist = True
                print(key)
                print(value)
    elif len(myfilters) == 1:
        print("Simple filter.")
        myonefilter = list()
        if re.search("=", filters):
            myonefilter = filters.split("=")
            key = myonefilter[0]
            value = myonefilter[1]
            myFilterDict[key] = value
            filters_exist = True
            print(key)
            print(value)
    else:
        filters_exist = False

    return(myFilterDict)


def simple_query(es, index_name, document_type, q, max_hits, filters):

    print("Simple query")

    size = '5'
    if max_hits <= 0:
        size = '10'
    else:
        size = str(max_hits)

    FilterDict = get_filters(filters)
    theFilter = ''

    if len(FilterDict) >= 1:
        theFilter = ', "filter" : [ '
        for key in FilterDict:
            theFilter = theFilter + \
                '{ "term" : { "' + key + '" : "' + FilterDict[key] + '"}},'
        theFilter = re.sub(r',$', '', theFilter)
        theFilter = theFilter + ']'

    print(theFilter)

    searchstring = ''
    regexpchar = re.compile('[\.\*\+\?\[\{\(\|]')
    if re.search(regexpchar, q):
        searchstring = '{"from": 0, "size": ' + size + ', "query": {"bool": {"must": [ {"regexp": {"rawText": "' + q + '"}} ]' + theFilter + \
            '}}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"rawText": {"type": "plain", "number_of_fragments": 0, "fragment_size": 1000 }}}}'
    else:
        searchstring = '{"from": 0, "size": ' + size + ', "query": {"bool": {"must": [ {"match": {"rawText": "' + q + '"}} ]' + theFilter + \
            '}}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"rawText": {"type": "plain", "number_of_fragments": 0, "fragment_size": 1000 }}}}'

    data = json.dumps({})
    tempdict = json.dumps(searchstring)
    data = json.loads(tempdict)

    print(data)

    result = es.search(index=index_name, doc_type=document_type, body=data)

    return result


def complex_query(es, index_name, document_type, q, max_hits, filters):

    print("Complex query")

    size = '5'
    if max_hits <= 0:
        size = '10'
    else:
        size = str(max_hits)

    mylist = list()
    if re.search(" ", q):
        mylist = q.split(" ")

    FilterDict = get_filters(filters)
    theFilter = ''

#    if len(FilterDict) >= 1:
#        theFilter = ' "filter" : [ '
#        for key in FilterDict:
#            theFilter = theFilter + '{ "term" : { "' + key + '" : "' + FilterDict[key] + '"}},'
#        theFilter = re.sub(r',$', '', theFilter)
#        theFilter = theFilter + '] '

    if len(FilterDict) >= 1:
        #"filter":{"bool":{"must":[{"term":{"areaCode":"sqp"}},{"term":{"textType":"spoken"}}]}}
        theFilter = ' "filter" : { "bool" : {"must": [ '
        for key in FilterDict:
            theFilter = theFilter + \
                '{ "term" : { "' + key + '" : "' + FilterDict[key] + '"}},'
        theFilter = re.sub(r',$', '', theFilter)
        theFilter = theFilter + ']}}}},'
    else:
        theFilter = '}},'

    print(theFilter)

    body_start = ''
    body_end = ''

    body_start = '{"from" : 0, "size" : ' + size + \
        ', "query" : { "bool" : { "must" : { "span_near" : { "clauses" : [ '
    if theFilter == '}},':
        body_end = ' ], "slop" : 0, "in_order" : "true" }}' + theFilter + ' "highlight" : {"pre_tags" : ["<em>"], "post_tags" :["</em>"], "fields":{"rawText":{ "type" : "plain", "number_of_fragments" : 10, "fragment_size":1000}}}}'
    else:
        body_end = ' ], "slop" : 0, "in_order" : "true" }},' + theFilter + ' "highlight" : {"pre_tags" : ["<em>"], "post_tags" :["</em>"], "fields":{"rawText":{ "type" : "plain", "number_of_fragments" : 10, "fragment_size":1000}}}}'

#    body_end = ' ], "slop" : 0, "in_order" : "true" }}}},' + theFilter + \
#        ' "highlight" : {"pre_tags" : ["<em>"], "post_tags" :["</em>"], "fields":{"rawText":{ "type" : "plain", "number_of_fragments" : 10, "fragment_size":1000}}}}'

    body_middle = list()
    searchterms = list()
    regexpchar = re.compile('[\.\*\+\?\[\{\(\|]')
    splitchar = re.compile(" ")
    searchterms = re.split(splitchar, q)
    for term in searchterms:
        term = term.strip()
        if re.search(regexpchar, term):
            to_append = ' { "span_multi" : { "match" : { "regexp": {"rawText": "' + term + '"}}}}'
#         to_append = ' { "span_multi" : { "match" : { "wildcard": {"rawText": "' + term + '"}}}}'
            body_middle.append(to_append)
        else:
            to_append = ' { "span_term" : { "rawText": "' + term + '" }}'
            body_middle.append(to_append)

    searchstring = ''
    for jsonpart in body_middle:
        searchstring = searchstring + jsonpart + ','

    searchstring = re.sub(r',$', '', searchstring)

    searchstring = body_start + searchstring + body_end

    print(searchstring)

    data = json.dumps({})
    tempdict = json.dumps(searchstring)
    data = json.loads(tempdict)

    print(data)

    result = es.search(index=index_name, doc_type=document_type, body=data)

    return result


# MAIN

input = sys.argv[1]

max_no_hits = 0
filters = ''
if len(sys.argv) <= 2:
    max_no_hits = 5
if len(sys.argv) > 2:
    max_no_hits = sys.argv[2]
if len(sys.argv) > 3:
    filters = sys.argv[3]

print(input)
print(max_no_hits)

#res = requests.get('http://localhost:9200')
# print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

query = input
query = query.strip()
if re.search(" ", query):
    result = complex_query(es, "cbf", "cbfraw", query, max_no_hits, filters)
else:
    result = simple_query(es, "cbf", "cbfraw", query, max_no_hits, filters)

# print(result)
# print("\n")

parsed_data = json.dumps(result)

# print(parsed_data)
# print("\n")

sunit = json.loads(parsed_data)

print(json.dumps(sunit, indent=4))
# print("\n")

print(sunit['hits']['total'])

# print(sunit['hits']['hits'][0]['highlight']['sunit'])
# print("\n")

para = list()
for row in sunit["hits"]["hits"]:
    print (row["_source"]["title"])
    print (row["_source"]["decade"])
    print (row["_source"]["sex"])
    print (row["_source"]["textId"])
    print (row["_source"]["sunitId"])
#    print row["highlight"]["sunit"]
#    print("\n")
#    para = row["highlight"]["rawText"]
    para = row["_source"]["rawText"]
    print(para)
    ind = 0
#    query = ' ' + query + ' '
    pattern = re.compile(query, flags=re.IGNORECASE)
    orig = ''
    rest = ''
    numberofmatches = 0
    endofqueryindex = 1000000
#    print(para.lower().find(query))
#    print(para.lower().rfind(query))
    for c in para:
        temp = para[ind:len(para)]
        if re.match(pattern, temp):
            numberofmatches += 1
            stringsofar = orig + '<b>' + temp
            orig = orig + '<b>'
            rest = para[ind:len(para)]
            print(rest)
            print(str(len(rest)))
            rest = re.sub(pattern, '', rest, 1)
            print(rest)
            print(str(len(rest)))
            print(str(len(para)))
            endofqueryindex = len(para) - len(rest)
            print(str(endofqueryindex))
#            print(temp)
#            print(stringsofar)
#            print(rest)
        if ind == endofqueryindex:
            orig = orig + '</b>'
        orig = orig + c
        ind += 1
#    print(str(numberofmatches))
#    print("\n")
    if numberofmatches > 1:
        for ind in range(0, numberofmatches):
            temp = orig
            temp = temp.replace('<b>', '<c>', 1)
            temp = temp.replace('</b>', '</c>', 1)
            temp = temp.replace('<b>', '')
            temp = temp.replace('</b>', '')
            temp = temp.replace('<c>', '<b>')
            temp = temp.replace('</c>', '</b>')
            print(temp)
#            print(orig)
            orig = orig.replace('<b>', '', 1)
            orig = orig.replace('</b>', '', 1)
    else:
        print(orig)
#    sentence = para[0]
#    print(query)
#    if re.search(pattern, para):
#        print("Found.")
#    replacePattern = '<b>' + query + '</b>'
#    highlighted = re.sub(pattern, replacePattern, para)
#    print(highlighted)
    words = para.split()
    for word in words:
        word = str(word)
        word = word.replace("<em>", "<hi>", 1)
        word = word[::-1]
        word = word.replace(">me/<", ">ih/<", 1)
        word = word[::-1]
        word = word.replace("<em>", "")
        word = word.replace("</em>", "")
#       print(word)
