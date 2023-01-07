# Import third-party modules, classes, and functions
from flask import Flask, jsonify, request
from flask_mongoengine import MongoEngine

# Import local modules, classes, and functions
from models import *

app = Flask(__name__)

app.config["MONGODB_SETTINGS"] = [
        {
            "db": "wnidel",
            "host": "localhost",
            "port": 27017,
            "alias": "default",
        }
]

db = MongoEngine()
db.init_app(app)

@app.route('/get-lexicographic-data/', methods=['GET'])
def get_lexicographic_data():
    print(request.args['word'])
    documents = A.objects(orthography__singular__iexact =
    request.args['word'])
    
    if len(documents):
        return jsonify(documents)
    else:
        return {}, 404, {'Access-Control-Allow-Origin': '*'}
