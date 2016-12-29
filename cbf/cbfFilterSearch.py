#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re, codecs, requests, json

from elasticsearch import Elasticsearch

reload(sys)
sys.setdefaultencoding( "utf-8" )

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

   size = 5
   if max_hits <= 0:
      size = 10
   else:
      size = max_hits

   FilterDict = get_filters(filters)
   theFilter = ''

   if len(FilterDict) >= 1:
      theFilter = ', "filter" : [ '
      for key in FilterDict:
         theFilter = theFilter + '{ "term" : { "' + key + '" : "' + FilterDict[key] + '"}},'
      theFilter = re.sub(r',$', '', theFilter)
      theFilter = theFilter + ']'

   print(theFilter)

   searchstring = ''
   regexpchar = re.compile('[\.\*\+\?\[\{\(\|]')
   if re.search(regexpchar, q):
      searchstring = '{"from": 0, "size": ' + size + ', "query": {"bool": {"must": [ {"regexp": {"rawText": "' + q + '"}} ]' + theFilter + '}}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"rawText": {"type": "plain", "number_of_fragments": 0, "fragment_size": 1000 }}}}'
   else:
      searchstring = '{"from": 0, "size": ' + size + ', "query": {"bool": {"must": [ {"match": {"rawText": "' + q + '"}} ]' + theFilter + '}}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"rawText": {"type": "plain", "number_of_fragments": 0, "fragment_size": 1000 }}}}'

   data = json.dumps({})
   tempdict = json.dumps(searchstring)
   data = json.loads(tempdict)

   print(data)

   result = es.search(index=index_name, doc_type=document_type, body=data)

   return result


def complex_query(es, index_name, document_type, q, max_hits, filters):

   print("Complex query")

     
   size = 5
   if max_hits <= 0:
      size = 10
   else:
      size = max_hits

   mylist = list()
   if re.search(" ", q):
      mylist = q.split(" ")

   FilterDict = get_filters(filters)
   theFilter = ''

   if len(FilterDict) >= 1:
#"filter":{"bool":{"must":[{"term":{"areaCode":"sqp"}},{"term":{"textType":"spoken"}}]}}
      theFilter = ' "filter" : { "bool" : {"must": [ '
      for key in FilterDict:
         theFilter = theFilter + '{ "term" : { "' + key + '" : "' + FilterDict[key] + '"}},'
      theFilter = re.sub(r',$', '', theFilter)
      theFilter = theFilter + ']}},'

   print(theFilter)
 
   body_start = '{"from" : 0, "size" : ' + size + ', "query" : { "bool" : { "must" : { "span_near" : { "clauses" : [ '
   body_end = ' ], "slop" : 0, "in_order" : "true" }}}},' + theFilter + '"highlight" : {"pre_tags" : ["<em>"], "post_tags" :["</em>"], "fields":{"rawText":{ "type" : "plain", "number_of_fragments" : 10, "fragment_size":1000}}}}'

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


#MAIN

input = sys.argv[1]

max_no_hits = 0
filters = ''
if len(sys.argv) > 2:
   max_no_hits = sys.argv[2]
if len(sys.argv) > 3:
   filters = sys.argv[3]

print(input)
#res = requests.get('http://localhost:9200')
#print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

query = input
query = query.strip()
if re.search(" ", query):
   result = complex_query(es, "cbf", "cbfraw", query, max_no_hits, filters)
else:
   result = simple_query(es, "cbf", "cbfraw", query, max_no_hits, filters)

#print(result)
#print("\n")

parsed_data = json.dumps(result)

#print(parsed_data)
#print("\n")

sunit = json.loads(parsed_data)

#print(json.dumps(sunit, indent=4))
#print("\n")

print(sunit['hits']['total'])

#print(sunit['hits']['hits'][0]['highlight']['sunit'])
#print("\n")

sentence = list()
for row in sunit["hits"]["hits"]:
    print (row["_source"]["title"])
    print (row["_source"]["decade"])
    print (row["_source"]["sex"])
    print (row["_source"]["textId"])
    print (row["_source"]["sunitId"])
#    print row["highlight"]["sunit"]
#    print("\n")
    sentence = row["highlight"]["rawText"]
#    print(sentence)
    for word in sentence:
       word = str(word)
       word = word.replace("<em>", "<hi>", 1)
       word = word[::-1]
       word = word.replace(">me/<", ">ih/<", 1)
       word = word[::-1]
       word = word.replace("<em>", "")
       word = word.replace("</em>", "")
       print(word)
