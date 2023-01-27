# Third party imports
import mongoengine as me

class Level2Subdivisions(me.EmbeddedDocument):
    no_1 = me.ListField(me.IntField(), default=None)
    no_2 = me.ListField(me.IntField(), default=None) 
    no_3 = me.ListField(me.IntField(), default=None) 

class Level1Subdivisions(me.EmbeddedDocument):
    meaning = me.ListField(me.IntField(), default=None) 
    a = me.ListField(me.IntField(), default=None)  
    b = me.ListField(me.IntField(), default=None)  
    c = me.ListField(me.IntField(), default=None)  
    d = me.ListField(me.IntField(), default=None)  
    e = me.ListField(me.IntField(), default=None)  
    f = me.ListField(me.IntField(), default=None) 
    g = me.ListField(me.IntField(), default=None) 
    h = me.ListField(me.IntField(), default=None)  
    i = me.ListField(me.IntField(), default=None)
    meaning_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions)
    a_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    b_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    c_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    d_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    e_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    f_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    g_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    h_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 
    i_subdivisions = me.EmbeddedDocumentField(Level2Subdivisions) 

class Phrases(me.EmbeddedDocument):
    no_1_phrase = me.ListField(me.IntField(), default=None)
    no_2_phrase = me.ListField(me.IntField(), default=None) 
    no_3_phrase = me.ListField(me.IntField(), default=None) 
    no_4_phrase = me.ListField(me.IntField(), default=None) 
    no_5_phrase = me.ListField(me.IntField(), default=None) 
    no_6_phrase = me.ListField(me.IntField(), default=None) 
    no_1_meaning = me.ListField(me.IntField(), default=None) 
    no_2_meaning = me.ListField(me.IntField(), default=None) 
    no_3_meaning = me.ListField(me.IntField(), default=None) 
    no_4_meaning = me.ListField(me.IntField(), default=None) 
    no_5_meaning = me.ListField(me.IntField(), default=None) 
    no_6_meaning = me.ListField(me.IntField(), default=None) 

class Meanings(me.EmbeddedDocument):
    meaning_1 = me.ListField(me.IntField(), default=None)
    meaning_2 = me.ListField(me.IntField(), default=None)
    meaning_3 = me.ListField(me.IntField(), default=None)
    meaning_1_subdivisions = me.EmbeddedDocumentField(Level1Subdivisions)
    meaning_2_subdivisions = me.EmbeddedDocumentField(Level1Subdivisions)
    meaning_3_subdivisions = me.EmbeddedDocumentField(Level1Subdivisions)
    phrases = me.EmbeddedDocumentField(Phrases)

class StartIndex(me.EmbeddedDocument):
    string = me.StringField()
    start_index = me.EmbeddedDocumentField(Meanings)

class UniqueOccurrences(me.EmbeddedDocument):
    no_1 = me.EmbeddedDocumentField(StartIndex)
    no_2 = me.EmbeddedDocumentField(StartIndex) 
    no_3 = me.EmbeddedDocumentField(StartIndex) 
    no_4 = me.EmbeddedDocumentField(StartIndex) 
    no_5 = me.EmbeddedDocumentField(StartIndex) 
    no_6 = me.EmbeddedDocumentField(StartIndex) 
    no_7 = me.EmbeddedDocumentField(StartIndex) 
    no_8 = me.EmbeddedDocumentField(StartIndex) 

class OrthographyWithAlternatives(me.EmbeddedDocument):
    preferred = me.ListField(me.StringField())
    alternatives = me.ListField(me.StringField())

class Orthography(me.EmbeddedDocument):
    singular = me.ListField(me.StringField(), default=None)
    plural = me.ListField(me.StringField(), default=None)
    singular_with_alternatives = me.EmbeddedDocumentField(OrthographyWithAlternatives)
    plural_with_alternatives = me.EmbeddedDocumentField(OrthographyWithAlternatives)

class BaseWordDocument(me.Document):
    abbreviations = me.EmbeddedDocumentField(UniqueOccurrences)
    bold = me.DictField()
    capital_required = me.DictField()
    cross_references = me.DictField()
    exclusiveness = me.DictField()
    inline_audio = me.DictField()
    italics = me.DictField()
    main_vocab = me.BooleanField()
    meanings = me.DictField()
    meta = {'abstract': True}
    minor_vocab = me.BooleanField()
    orthoepy = me.DictField()
    orthography = me.EmbeddedDocumentField(Orthography)
    part_of_speech = me.StringField()
    phrases = me.DictField()
    quotations = me.DictField()
    subjects = me.DictField()
    transliterations = me.DictField()

class A(BaseWordDocument):
    collection = "a"
