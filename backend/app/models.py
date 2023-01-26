# Import third-party modules, classes, and functions
import flask_mongoengine
from mongoengine import *

class Level2StartIndex(EmbeddedDocument):
    no_1 = ListField(IntField(), default=None)
    no_2 = ListField(IntField(), default=None) 
    no_3 = ListField(IntField(), default=None) 

class Level1StartIndex(EmbeddedDocument):
    meaning = ListField(IntField(), default=None) 
    a = ListField(IntField(), default=None)  
    b = ListField(IntField(), default=None)  
    c = ListField(IntField(), default=None)  
    d = ListField(IntField(), default=None)  
    e = ListField(IntField(), default=None)  
    f = ListField(IntField(), default=None) 
    g = ListField(IntField(), default=None) 
    h = ListField(IntField(), default=None)  
    i = ListField(IntField(), default=None)
    meaning_with_levels = EmbeddedDocumentField(Level2StartIndex)
    a_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    b_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    c_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    d_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    e_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    f_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    g_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    h_with_levels = EmbeddedDocumentField(Level2StartIndex) 
    i_with_levels = EmbeddedDocumentField(Level2StartIndex) 

class StartIndex(EmbeddedDocument):
    meaning_1 = ListField(IntField(), default=None)
    meaning_2 = ListField(IntField(), default=None)
    meaning_3 = ListField(IntField(), default=None)
    meaning_1_with_levels = EmbeddedDocumentField(Level1StartIndex)
    meaning_2_with_levels = EmbeddedDocumentField(Level1StartIndex)
    meaning_3_with_levels = EmbeddedDocumentField(Level1StartIndex)

class StringLocations(EmbeddedDocument):
    string = StringField()
    start_index = EmbeddedDocumentField(StartIndex)

class OrthographyWithAlternatives(EmbeddedDocument):
    preferred = ListField(StringField())
    alternatives = ListField(StringField())

class Orthography(EmbeddedDocument):
    singular = ListField(StringField(), default=None)
    plural = ListField(StringField(), default=None)
    singular_with_alternatives = EmbeddedDocumentField(OrthographyWithAlternatives)
    plural_with_alternatives = EmbeddedDocumentField(OrthographyWithAlternatives)

class BaseWordDocument(flask_mongoengine.Document):
    abbreviations = EmbeddedDocumentField(StringLocations)
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
