# Import standard modules, classes, and functions
from urllib.parse import quote_plus

# Import third-party modules, classes, and functions
import bsonjs
from bson.raw_bson import RawBSONDocument
from flask import Flask, request
from pymongo import MongoClient

app = Flask(__name__)

socket_path = '/tmp/mongodb-27017.sock'
uri = 'mongodb://%s' % (quote_plus(socket_path))
client = MongoClient(uri, document_class=RawBSONDocument)
db = client.wnidel

collections = db.list_collection_names()

@app.route('/get-lexicographic-data/', methods=['GET'])
def get_lexicographic_data():
    print(request.args['word'])
    
    if len(request.args['word']) == 1:
        if request.args['word'] in collections:
            documents = []
            for document in db[request.args['word']].find():
                documents.append(bsonjs.dumps(document.raw))
            return documents 
        else:
            return {}, 404, {'Access-Control-Allow-Origin': '*'}
