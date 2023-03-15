extends Node2D

var util : GameUtil = GameUtil.new()
var currentLevel : Level = Level.new()
var selectedCards : Array = []
var sets : Array = []
var foundSets : Array = []
var cats : Array = []
var summon : Cat = null
var rarityIndex : int = 0

onready var board : Board = $Screen/CenterContainer/Board
onready var foundBoard : Board = $Screen/FoundBoard

var cameraFocus : Vector2
var zoom : Vector2 = Vector2.ONE
var summonColor : Color = Color(0, 0, 0, 0)

onready var cardScene = load(Globals.cardScenePath)
onready var cardTexture = load(Globals.cardTexturePath)

onready var victoryUI = $Camera2D/CanvasLayer/VictoryUI
onready var book = $Camera2D/CanvasLayer/ClosedBook
onready var bookPos = book.rect_position

enum GameState { TALK, PLAY }
var state = GameState.PLAY

var tutorialText : Dictionary = {
	0 : ["Welcome, fledgling.",
		"I am [color=red]Yarf[/color], the Grand Spat of Old.", 
		"Those who were lost in the [color=red]Great Hairball[/color]...",
		"We'll be bringing them back with my knowledge and your potential.",
		"Are you aware of the arcanic arts of [color=red]Set[/color]?",
		"Three incantations are required to make a [color=red]set[/color].",
		"The [color=red]runes[/color] before you have magical properties.",
		"[color=red]Color[/color], [color=red]shape[/color], [color=red]fill[/color], and [color=red]count[/color].",
		"When making a [color=red]set[/color], all of these properties must either match, or be unique with each [color=red]rune[/color].",
		"The [color=red]runes[/color] here, fledgling, do you see it?",
		"They all share the same [color=red]shape[/color], [color=red]fill[/color], and [color=red]count[/color], but differ in [color=red]color[/color].",
		"Show me your promise, fledgling. Enact the summoning."
		],
	1 : ["You did well, fledgling.",
		"The properties of these [color=red]runes[/color] have nothing in common.",
		"Not a single one.",
		"Yet, they are ripe for summoning.",
		"Magic is fun, isn't it, fledgling?"
		],
	2 : ["Do not misunderstand magic with miracles, fledgling.",
		"To bring forth the vast underworld, our incantations grow more complex.",
		"Not all [color=red]runes[/color] serve our purpose.",
		"Some simply have no place in a [color=red]set[/color], given the conditions.",
		"Find me one [color=red]set[/color] within these [color=red]runes[/color]."
		],
	3 : ["Are you intimidated, fledgling?",
		"This next summoning will require 2 [color=red]sets[/color].",
		"Do not be afraid to seek my counsel.",
		"Pat my [color=red]heady head[/color] to view my accumulated wisdom.",
		"Also, take notice of any [color=red]crows[/color].",
		"They are allies of the underworld.",
		"Give their feathers a rustle if you require a [color=red]hint[/color].",
		"Good luck, fledgling."
		],
	10 : ["Thanks for playing!",
		"We'd love if you could give us feedback on this demo.",
		"Join our [color=blue][url=https://discord.gg/af9ha8Q4cb]Discord[/url][/color], comment on [color=blue][url=https://galitie.itch.io/cat-summoner]Itch[/url][/color], or fill out this [color=blue][url=https://forms.gle/F1Xfwp1YYDRrNjxK8]Google Form[/url][/color].",
		"Until next time!",
		"...This level is unbeatable, by the way.",
		"I'm serious! Don't bother trying."
	]
}
var messageIndex : int = 0
var textIndex : float = 0
var textSpeed : float = 30
var scrollOpened : bool = false

onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var hintLength : int = 120

func _ready() -> void:
	$HintTimer.one_shot = true
	
	$Camera2D.offset = $Screen.rect_size / 2
	cameraFocus = $Camera2D.offset
	
	cats = util.LoadCatData()
	
	GoToLevel(0)

func GoToLevel(index) -> void:
	$Camera2D/CanvasLayer/TextBox.visible = false
		
	selectedCards.clear()
	sets.clear()
	foundSets.clear()
	
	cameraFocus = $Screen.rect_size / 2
	zoom = Vector2.ONE
	
	rng.randomize()
	rarityIndex = 0
	var raritySize = cats[rarityIndex].size()
	while !raritySize:
		rarityIndex += 1
		raritySize = cats[rarityIndex].size()
	
	var summonIndex : int = rng.randi_range(0, cats[rarityIndex].size() - 1)
	summon = cats[rarityIndex][summonIndex]
	$Screen/Altar/Summon.texture = load(summon.summonImagePath)
	
	currentLevel = ResourceLoader.load("res://levels/level" + String(index) + ".tres")
	if currentLevel.shuffle:
		currentLevel.layout.shuffle()
	
	board.SetLayout(currentLevel.layout, cardScene)
	sets = util.FindSets(currentLevel.layout)
	
	book.visible = false
	summonColor = Color(0, 0, 0, 0)
	$Screen/Altar/Summon.modulate = summonColor
	victoryUI.visible = false
	
	if tutorialText.has(index):
		board.interactable = false
		yield(get_tree().create_timer(1), "timeout")
		state = GameState.TALK
		$Camera2D/CanvasLayer/TextBox/Text.visible_characters = 0
		$Camera2D/CanvasLayer/TextBox.visible = true
		messageIndex = 0
		$Camera2D/CanvasLayer/TextBox/Text.bbcode_text = "[center]" + tutorialText[index][messageIndex] + "[/center]"
		$Camera2D/CanvasLayer/TextBox/Text.set_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_WIDTH, 0) 
	else:
		board.interactable = true
		$HintTimer.start(hintLength)

func GenerateSetID(set) -> int:
	var id : Array = [util.BitID(set[0]), util.BitID(set[1]), util.BitID(set[2])]
	id.sort()
	return id.hash()

func _physics_process(delta) -> void:
	match state:
		GameState.TALK:
			if scrollOpened:
				$Screen/TutorialCat.animation = "TalkingOpen"
			else:
				$Screen/TutorialCat.animation = "TalkingClosed"
			$Screen/TutorialCat.playing = true
			textIndex = clamp(textIndex + textSpeed * delta, 0, $Camera2D/CanvasLayer/TextBox/Text.get_total_character_count())
			$Camera2D/CanvasLayer/TextBox/Text.visible_characters = textIndex
			if int(textIndex) == $Camera2D/CanvasLayer/TextBox/Text.get_total_character_count():
				$Camera2D/CanvasLayer/TextBox/Confirmation.visible = true
				if Input.is_action_just_pressed("Select"):
					messageIndex += 1
					$Camera2D/CanvasLayer/TextBox/Confirmation.visible = false
					$Camera2D/CanvasLayer/TextBox/Text.visible_characters = 0
					if messageIndex < tutorialText[currentLevel.index].size():
						$Camera2D/CanvasLayer/TextBox/Text.bbcode_text = "[center]" + tutorialText[currentLevel.index][messageIndex] + "[/center]"
					else:
						board.interactable = true
						$Camera2D/CanvasLayer/TextBox.visible = false
						state = GameState.PLAY
						$Screen/TutorialCat.playing = false
						$HintTimer.start(hintLength)
					$Camera2D/CanvasLayer/TextBox/Text.set_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_WIDTH, 0) 
					textIndex = 0
			else:
				if Input.is_action_just_pressed("Select"):
					textIndex = $Camera2D/CanvasLayer/TextBox/Text.get_total_character_count()
		GameState.PLAY:
			var spaceState = get_world_2d().direct_space_state
			var mousePos = get_global_mouse_position()
			var result = spaceState.intersect_point(mousePos, 1, [], 2147483647, true, true)
			if result:
				if Input.is_action_just_pressed("Select"):
					match result[0].collider.get_parent().name:
						"TutorialCat":
							scrollOpened = !scrollOpened
							if scrollOpened:
								$Screen/TutorialCat.animation = "TalkingOpen"
							else:
								$Screen/TutorialCat.animation = "TalkingClosed"
							$Screen/TutorialCat/Scroll.visible = scrollOpened
						"Crow":
							Hint()
							$Screen/Crow.get_node("AnimationPlayer").play("FlyOut")
							$HintTimer.start(hintLength)
			
			if board.interactable:
				var hoveredCard : Card = board.GetCard()
				if hoveredCard:
					if Input.is_action_just_pressed("Select"):
						if selectedCards.has(hoveredCard):
							selectedCards.erase(hoveredCard)
							hoveredCard.get_node("AnimationPlayer").play("Deselected")
						else:
							selectedCards.push_back(hoveredCard)
							if selectedCards.size() < 3:
								hoveredCard.get_node("AnimationPlayer").play("Selected")
	
	$Camera2D.offset = lerp($Camera2D.offset, cameraFocus, 5 * delta)
	$Camera2D.zoom = lerp($Camera2D.zoom, zoom, 3 * delta)
	$Screen/Altar/Summon.modulate = lerp($Screen/Altar/Summon.modulate, summonColor, 5 * delta)
	
	if book.visible:
		book.rect_position.y = lerp(book.rect_position.y, bookPos.y, 7 * delta)
	
	if selectedCards.size() >= 3:
		var isFound : bool = false
		var selectedInfo : Array = [selectedCards[0].info, selectedCards[1].info, selectedCards[2].info]
		var selectedID : int = GenerateSetID(selectedInfo)
		for set in sets:
			var setID : int = GenerateSetID(set)
			if selectedID == setID:
				isFound = true
				if foundSets.has(selectedID):
					print("DUMBERS")
				else:
					if $HintTimer.time_left:
						$HintTimer.start(hintLength)
					foundSets.push_back(selectedID)
					summonColor.a = float(foundSets.size()) / float(currentLevel.setsToWin)
					var childIndex = (foundSets.size() * 3) - 3
					for i in 3:
						foundBoard.get_child(childIndex).SetInfo(selectedCards[i].info)
						childIndex += 1
					if foundSets.size() == currentLevel.setsToWin:
						selectedCards.clear()
						Victory()
		for card in selectedCards:
			if isFound:
				card.get_node("AnimationPlayer").play("Correct", 0)
			else:
				card.get_node("AnimationPlayer").play("Incorrect", 0)
			
		selectedCards.clear()

func Hint() -> void:
	var unknownSets : Array = sets.duplicate()
	for set in unknownSets:
		var setID : int = GenerateSetID(set)
		if foundSets.has(setID):
			unknownSets.erase(set)
	var setIndex : int = rng.randi_range(0, unknownSets.size() - 1)
	var cardIndex : int = rng.randi_range(0, unknownSets[setIndex].size() - 1)
	for card in board.get_children():
		if card.info == unknownSets[setIndex][cardIndex]:
				card.get_node("AnimationPlayer").play("Hint")

func Victory() -> void:
	if !$HintTimer.time_left:
		$Screen/Crow.get_node("AnimationPlayer").play("FlyOut")
	$HintTimer.stop()
	board.interactable = false
	for card in board.get_children():
		card.get_node("AnimationPlayer").stop(true)
		card.get_node("AnimationPlayer").play("Victory", 0)
	
	yield(get_tree().create_timer(1), "timeout")
	cameraFocus = $Screen/Altar/Summon/Focus.rect_global_position
	zoom = Vector2(0.6, 0.6)
	
	yield(get_tree().create_timer(1.5), "timeout")
	summonColor = Color(1, 1, 1, 1)
	
	yield(get_tree().create_timer(1), "timeout")
	cameraFocus = $Screen/Altar/Summon/Focus2.rect_global_position
	book.visible = true
	book.rect_position.y = $Screen.rect_size.y
	
	yield(get_tree().create_timer(1), "timeout")
	book.visible = false
	victoryUI.visible = true
	victoryUI.get_node("Book/Name").text = summon.name
	victoryUI.get_node("Book/Story").text = summon.story
	
	cats[rarityIndex].erase(summon)
	Globals.unlockedCats.push_back(summon)

func _on_NextLevelButton_pressed() -> void:
	GoToLevel(currentLevel.index + 1)

func _on_WinButton_pressed() -> void:
	Victory()

func _on_HintTimer_timeout():
	$Screen/Crow.get_node("AnimationPlayer").play("FlyIn")

func _on_Text_meta_clicked(meta):
	OS.shell_open(str(meta))
