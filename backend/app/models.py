# Import third-party modules, classes, and functions
from mongoengine import * 

class Orthoepy(EmbeddedDocument):
    plural = ListField(StringField())
    singular = ListField(StringField())

class BaseWordDocument(Document):
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
    orthography = DictField()
    part_of_speech = StringField()
    subjects = DictField()
    transliterations = DictField()

class A(BaseWordDocument):
    collection = "a"
