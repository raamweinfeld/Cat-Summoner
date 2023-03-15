class_name GameUtil

func CreateDeck() -> Array:
	var deck : Array = []
	for color in 3:
		for pattern in 3:
			for shape in 3:
				for count in range(1, 4):
					deck.append(CardInfo.new(color, pattern, shape, count))
	return deck
	
func DrawFromDeck(deck, numCards) -> Array:
	var hand : Array = []
	randomize()
	for i in numCards:
		var randInfo = deck[randi() % deck.size()]
		hand.push_back(randInfo)
		deck.erase(randInfo)
	return hand

func FindSets(layout) -> Array:
	var sets : Array = []
	var cardIndexA = 0
	var cardIndexB = cardIndexA + 1
	while cardIndexA < layout.size() - 1:
		var outputAB : int = BitID(layout[cardIndexA]) & BitID(layout[cardIndexB])
		for i in range(cardIndexB, layout.size()):
			var outputBC : int = BitID(layout[cardIndexB]) & BitID(layout[i])
			var outputAC : int = BitID(layout[cardIndexA]) & BitID(layout[i])
			if outputAB == outputBC && outputBC == outputAC:
				var set : Array = [layout[cardIndexA], layout[cardIndexB], layout[i]]
				sets.push_back(set)
		cardIndexB += 1
		if cardIndexB > layout.size() - 1:
			cardIndexA += 1
			cardIndexB = cardIndexA + 1
	return sets
	
func BitID(info) -> int:
	var id : int = 0
	id = (1 << info.color) + (1 << 3 + info.pattern) + (1 << 6 + info.shape) + (1 << 9 + (info.count - 1))
	return id

func LoadCatData() -> Array:
	var catList : CatList = ResourceLoader.load("res://data/cat_list.tres")
	var catArray : Array = []
	for i in Cat.Rarity.TOTAL:
		catArray.push_back([])
	for cat in catList.list:
		catArray[cat.rarity].push_back(cat)
	
	return catArray
