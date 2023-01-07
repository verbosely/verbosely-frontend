# Import third-party modules, classes, and functions
import flask_mongoengine
from mongoengine import *

class Orthoepy(EmbeddedDocument):
    plural = ListField(StringField())
    singular = ListField(StringField())

class Orthography(EmbeddedDocument):
    plural = ListField(StringField())
    singular = ListField(StringField())

class BaseWordDocument(flask_mongoengine.Document):
    abbreviations = DictField()
    bold = DictField()
    capital_required = DictField()
    cross_references = DictField()
    italics = DictField()
    main_vocab = BooleanField()
    meanings = DictField()
    meta = {'abstract': True}
    minor_vocab = BooleanField()
    orthoepy = EmbeddedDocumentField(Orthoepy)
    orthography = EmbeddedDocumentField(Orthography)
    part_of_speech = StringField()
    subjects = DictField()
    transliterations = DictField()

class A(BaseWordDocument):
    collection = "a"
