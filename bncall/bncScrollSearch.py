#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
import sys, os, re, requests, json
from elasticsearch import Elasticsearch

reload(sys)
sys.setdefaultencoding("utf-8")

# FUNCTIONS
def create_mask(query_string):
   
   splitchar = re.compile(" ")
   searchterms = re.split(splitchar, query_string)
   mask = ''
   noofmasks = 0
   for term in searchterms:
#      term = term.strip()
      noofmasks += 1
#      mask = mask + '(.+) '
      mask = mask + '([^ ]+) '

   mask = re.sub(r' $', '', mask)
   mask = '<hi>' + mask + '</hi>'

   return (mask, noofmasks)

def create_query(query_string):
   
   theQuery = ''
   query_string = query_string.replace('> [', '> .+ [')
   query_string = query_string.replace('] [', '] .+ .+ [')
   query_string = query_string.replace('> <', '> .+ .+ <')
   query_string = query_string.replace('] <', '] .+ .+ .+ .+ <')
#   pat1 = re.compile('([a-z0-9øæåäëïöüâêîôûãñõçàèìòùáéíóúðßÞ])')

   query_string = re.sub(r'\] ([a-z0-9øæåäëïöüâêîôûãñõçàèìòùáéíóúðßÞ\'-])', r'] .+ \1', query_string)
   query_string = re.sub(r'([a-z0-9øæåäëïöüâêîôûãñõçàèìòùáéíóúðßÞ\'-]) <', r'\1 .+ .+ .+ .+ <', query_string)

   splitchar = re.compile(" ")
   searchterms = re.split(splitchar, query_string)
   mystring = ''
   for term in searchterms:
      term = term.strip()
      if re.match('<', term):
         term = term.replace('<', '')
         term = term.replace('>', '')
         term = term.upper()
      elif re.match('\[', term):
         term = term.replace('[', '')
         term = term.replace(']', '')
         term = term.upper()
      else:
         term = term
      mystring = str(term)
      theQuery = theQuery + mystring + ' '

#  theQuery = query_string
   theQuery = re.sub(r' $', '', theQuery)

   return theQuery

def get_adjusted_text(mixed, raw):
   
   theAdjusted = ''
   raw = re.sub(r'([A-Za-z0-9øæåäëïöüâêîôûãñõçàèìòùáéíóúðßÞ])\'([A-Za-z])', r"\1 '\2", raw)
   raw = re.sub(r'([A-Za-z0-9øæåäëïöüâêîôûãñõçàèìòùáéíóúðßÞ])\.\.\.([A-Za-z])', r"\1... \2", raw)
   raw = re.sub(r'([sS])\' ', r"\1 ' ", raw)
   raw = raw.replace(" -- ", " ")
   raw = raw.replace(" , ", ", ")
#   print(raw)
   raw = raw.strip()
   anewlist = ()
   remixed = re.split(" ", mixed)
   newRaw = re.split(" ", raw)
   Rind = -1
   lengde = len(remixed) - 1
   for ind in xrange(0,lengde,3):
      Rind += 1
      if Rind >= len(newRaw):
         break
      mystring = remixed[ind] + remixed[ind+1] + remixed[ind+2]
#      print(remixed[ind])
#      print(remixed[ind+1])
#      print(remixed[ind+2])
#      print(newRaw[Rind])
      if re.search("<hi>", mystring):
         theAdjusted = theAdjusted + '<hi>' + newRaw[Rind] + ' '
      elif re.search("</hi>", mystring):
         theAdjusted = theAdjusted + newRaw[Rind] + '</hi>' + ' '
      else:
         theAdjusted = theAdjusted + newRaw[Rind] + ' '

   theAdjusted = re.sub(r' $', '', theAdjusted)
   theAdjusted = re.sub(r'<hi>(["\?.,;!\)\(:-]+)', r'\1<hi>', theAdjusted)
   theAdjusted = re.sub(r'(["\?.,;!\(\):-]+)</hi>', r'</hi>\1', theAdjusted)

   return theAdjusted


def mixed_search(es, index_name, document_type, q, max_hits, filters):

   print(q)
   mylist = list()
   if re.search(" ", q):
      mylist = q.split(" ")

   size = 5
   if max_hits <= 0:
      size = 10
   else:
      size = max_hits

   body_start = '{"from" : 0, "size": ' + size + ', "query":{ "span_near" : { "clauses" : [ '

   body_middle = list()
   searchterms = list()
   regexpchar = re.compile('[\.\*\+\?\[\{\(\|]')
   splitchar = re.compile(" ")
   searchterms = re.split(splitchar, q)
   span = 0
   for term in searchterms:
      term = term.strip()
      if term == '.*' or term == '.+':
         span = span + 1
#         print(term)
      else:
         if re.search(regexpchar, term):
            to_append = ' { "span_multi" : { "match" : { "regexp": {"mixed": "' + term + '"}}}}'
            body_middle.append(to_append)
         else:
            to_append = ' { "span_term" : { "mixed": "' + term + '" }}'
            body_middle.append(to_append)
         span = span + 1

   searchstring = ''
   for jsonpart in body_middle:
      searchstring = searchstring + jsonpart + ','

   searchstring = re.sub(r',$', '', searchstring)

   print(span)
   body_end = ' ], "slop" : ' + str(span) + ', "in_order" : "true" }}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"mixed": {"type": "plain", "number_of_fragments": 10, "fragment_size": 1000}}}}'

   searchstring = body_start + searchstring + body_end

#   searchstring = ' {"from" : 0, "size": 10, "query":{ "span_near" : { "clauses" : [ { "span_term" : { "sunit": "it" }}, { "span_term" : { "sunit": "was" }}, { "span_multi" : { "match" : { "regexp": {"sunit": ".*"}}}}, { "span_term" : { "sunit": "that" }} ], "slop" : 0, "in_order" : "true" }}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"sunit": {}}}}'

   data = json.dumps({})
   tempdict = json.dumps(searchstring)
   data = json.loads(tempdict)

#   print(data)

#   print("Hei")
   result = es.search(index=index_name, doc_type=document_type, scroll="5m", body=data, request_timeout=60)

   return result

def scrolling(es, sid):

      thescroll = '{"scroll_id" : ' + sid + '}'
      scrollresult = es.scroll(scroll="5m", scroll_id=sid, request_timeout=60)

      return scrollresult


#MAIN
input = sys.argv[1]

max_no_hits = 0
filters = ''
if len(sys.argv) > 2:
   max_no_hits = sys.argv[2]
if len(sys.argv) > 3:
   filters = sys.argv[3]

#print(input)
#res = requests.get('http://localhost:9200')
#print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

query = input
query = create_query(query)
#print(query)

result = mixed_search(es, "bnces", "bncall", query, max_no_hits, filters)

(mask, noMasks) = create_mask(query)
#print(mask)
#print(noMasks)

#print(result)
#print("\n")

parsed_data = json.dumps(result)

#print(parsed_data)
#print("\n")

sunit = json.loads(parsed_data)

#print(json.dumps(sunit, indent=4))
#print("\n")

print(sunit['hits']['total'])
for row in sunit["hits"]["hits"]:
      tid = row["_source"]["sunitId"]
      print(tid)

#print(sunit['_scroll_id'])

scrollId = sunit['_scroll_id']
while sunit["hits"]["hits"]:
      newresult = scrolling(es, scrollId)
      parsed_data = json.dumps(newresult)
      sunit = json.loads(parsed_data)
      for row in sunit["hits"]["hits"]:
            tid = row["_source"]["sunitId"]
            print(tid)

#print(sunit['hits']['hits'])

#print(sunit['hits']['hits'][0]['highlight']['rawText'])
#print("\n")

#sentence = list()
#for row in sunit["hits"]["hits"]:
#    tid = row["_source"]["sunitId"]
#    print(tid)
#    print row["_source"]["rawText"]
#    rawtext = row["_source"]["rawText"]
#    print row["_source"]["lemma"]
#    print row["_source"]["pos"]
#    print row["highlight"]["sunit"]
#    print("\n")
#    sentence = row["highlight"]["mixed"]
#    print(sentence)
#    for word in sentence:
#       word = str(word)
#       print(word)
#       word = word.replace("<em>", "<hi>", 1)
#       word = word[::-1]
#       word = word.replace(">me/<", ">ih/<", 1)
#       word = word[::-1]
#       word = word.replace("<em>", "")
#       word = word.replace("</em>", "")
#       print(mask)
#       print(word)
#       if re.search(mask, word):
#          print(word)
#         adjusted = get_adjusted_text(word, rawtext)
#          print (tid, end="")
#          print ("\t", end="")
#          print(adjusted)

sys.exit()
