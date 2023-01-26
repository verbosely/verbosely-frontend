# Import third-party modules, classes, and functions
import flask_mongoengine
from mongoengine import *

class OrthographyWithAlternatives(EmbeddedDocument):
    preferred = ListField(StringField())
    alternatives = ListField(StringField())

class Orthography(EmbeddedDocument):
    singular = ListField(StringField(), default=None)
    plural = ListField(StringField(), default=None)
    singular_with_alternatives = EmbeddedDocumentField(OrthographyWithAlternatives)
    plural_with_alternatives = EmbeddedDocumentField(OrthographyWithAlternatives)

class BaseWordDocument(flask_mongoengine.Document):
    abbreviations = DictField()
    bold = DictField()
    capital_required = DictField()
    cross_references = DictField()
    exclusiveness = DictField()
    inline_audio = DictField()
    italics = DictField()
    main_vocab = BooleanField()
    meanings = DictField()
    meta = {'abstract': True}
    minor_vocab = BooleanField()
    orthoepy = DictField()
    orthography = EmbeddedDocumentField(Orthography)
    part_of_speech = StringField()
    phrases = DictField()
    quotations = DictField()
    subjects = DictField()
    transliterations = DictField()

class A(BaseWordDocument):
    collection = "a"
