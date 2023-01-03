# Import third-party modules, classes, and functions
from flask import Flask, make_response
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

@app.route("/")
def test():
    return "<p>apples.</p>"

@app.route('/get-lexicographic-data/', methods=['GET'])
def get_lexicographic_data():
    #response = make_response()
    #print(response.status)
    return {}
