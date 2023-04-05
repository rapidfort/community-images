"""The test for elasticsearch."""
#!/usr/bin/env python3
import getopt
import sys

from datetime import datetime
from elasticsearch import Elasticsearch # pylint: disable=import-error

# pylint: disable=invalid-name
try:
    opts, args = getopt.getopt(sys.argv[1:], "s:", ["es-server="])
except getopt.GetoptError:
    print('python3 publish.py --es-server <server>')
    sys.exit(2)
for opt, arg in opts:
    if opt in ("--es-server", "--s"):
        server = arg

es = Elasticsearch(f'http://es-bcontainer:9200')

doc = {
    'author': 'test_author',
    'text': 'Interensting content...',
    'timestamp': datetime.now(),
}
resp = es.index(index="test-index", id=1, document=doc)
print(resp['result'])

# get the document
resp = es.get(index="test-index", id=1)
print(resp['_source'])

# refresh the indices
es.indices.refresh(index="test-index")

# search within the doc
resp = es.search(index="test-index", query={"match_all": {}})
print("Got %d Hits:" % resp['hits']['total']['value']) # pylint: disable=consider-using-f-string
for hit in resp['hits']['hits']:
    print("%(timestamp)s %(author)s: %(text)s" % hit["_source"]) # pylint: disable=consider-using-f-string

# updating the document
doc = {
    'author': 'test_author',
    'text': 'Interensting modified content...',
    'timestamp': datetime.now(),
}
resp = es.update(index="test-index", id=1, doc=doc)
print(resp['result'])

# delete the document
es.delete(index="test-index", id=1)
