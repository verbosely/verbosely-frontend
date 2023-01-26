# Third party imports
import mongoengine as me

class Level2StartIndex(me.EmbeddedDocument):
    no_1 = me.ListField(me.IntField(), default=None)
    no_2 = me.ListField(me.IntField(), default=None) 
    no_3 = me.ListField(me.IntField(), default=None) 

class Level1StartIndex(me.EmbeddedDocument):
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
    meaning_with_levels = me.EmbeddedDocumentField(Level2StartIndex)
    a_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    b_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    c_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    d_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    e_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    f_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    g_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    h_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 
    i_with_levels = me.EmbeddedDocumentField(Level2StartIndex) 

class StartIndex(me.EmbeddedDocument):
    meaning_1 = me.ListField(me.IntField(), default=None)
    meaning_2 = me.ListField(me.IntField(), default=None)
    meaning_3 = me.ListField(me.IntField(), default=None)
    meaning_1_with_levels = me.EmbeddedDocumentField(Level1StartIndex)
    meaning_2_with_levels = me.EmbeddedDocumentField(Level1StartIndex)
    meaning_3_with_levels = me.EmbeddedDocumentField(Level1StartIndex)

class StringLocations(me.EmbeddedDocument):
    string = me.StringField()
    start_index = me.EmbeddedDocumentField(StartIndex)

class UniqueOccurrences(me.EmbeddedDocument):
    no_1 = me.EmbeddedDocumentField(StringLocations)
    no_2 = me.EmbeddedDocumentField(StringLocations) 
    no_3 = me.EmbeddedDocumentField(StringLocations) 
    no_4 = me.EmbeddedDocumentField(StringLocations) 
    no_5 = me.EmbeddedDocumentField(StringLocations) 
    no_6 = me.EmbeddedDocumentField(StringLocations) 
    no_7 = me.EmbeddedDocumentField(StringLocations) 
    no_8 = me.EmbeddedDocumentField(StringLocations) 

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
