#!/bin/sh
curl -XDELETE http://localhost:9200/bnces/
echo ""
echo "Deleted the BNC index"
/home/jarlee/prog/script/python/bnc/all/bncMap.py
echo "Created 'BNCES' and mapped the fields"
#/home/jarlee/prog/script/python/ice/iceSimpleIndex.py /home/jarlee/prog/script/p
