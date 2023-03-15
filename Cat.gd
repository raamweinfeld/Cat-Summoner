extends Resource
class_name Cat

enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY, TOTAL }

export var summonImagePath : String
export var name : String
export var story : String
export var secretStory : String
export var rarity : int
export var globalID : int
export var dateID : int
#soundPath

func _init(p_name = "NEWENTRY", p_rarity = Rarity.COMMON, p_story = ""):
	name = p_name
	rarity = p_rarity
	story = p_story
