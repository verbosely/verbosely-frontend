# Import third-party modules, classes, and functions
from mongoengine import * 

class Orthoepy(EmbeddedDocument):
    singular = ListField(StringField())
    plural = ListField(StringField())

class BaseWordDocument(Document):
    main_vocab = BooleanField()
    minor_vocab = BooleanField()
    part_of_speech = StringField()
    orthography = DictField()
    orthoepy = EmbeddedDocumentField(Orthoepy)
    meanings = DictField()
    abbreviations = DictField()
    hyperlinks = DictField()
    transliterations = DictField()
    italics = DictField()
    bold = DictField()
    meta = {'abstract': True}

class A(BaseWordDocument):
    collection = "a"
