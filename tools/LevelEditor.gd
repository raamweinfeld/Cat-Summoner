extends Node

var util : GameUtil = GameUtil.new()
onready var cardEditScene = load("res://tools/cardedit.tscn")

onready var cardScene = load(Globals.cardScenePath)
onready var cardTexture = load(Globals.cardTexturePath)
onready var currentLevel : Level = Level.new()
var genNumCards : int = 0
var genSets : int = 0
onready var board : Board = $CenterContainer/Board
onready var previewBoard : Board = $"Control/Panel/SolutionsTab/Set Solutions/ScrollContainer/PreviewBoard"

onready var indexField = $Control/Panel/SettingsTab/Settings/LevelIndexLabel/LevelIndex
onready var setsToWinField = $Control/Panel/SettingsTab/Settings/SetsToWinLabel/SetsToWin
onready var timerField = $Control/Panel/SettingsTab/Settings/TimerLabel/Timer
onready var shuffleToggle = $Control/Panel/SettingsTab/Settings/Shuffle
onready var saveConfirmation = $Control/ConfirmationDialog
onready var fileDialog = $Control/FileDialog

var prevCard : Card = null

func _ready():
	$ModeOption.add_item("TUTORIAL")
	$ModeOption.add_item("FIXED")
	
func _process(delta):
	if board.cardSelected:
		board.cardSelected = false
		board.lastSelectedCard.get_node("AnimationPlayer").play("Selected")
		if !prevCard:
			prevCard = board.lastSelectedCard
		elif prevCard == board.lastSelectedCard:
			board.lastSelectedCard.get_node("AnimationPlayer").play("Deselected")			
			prevCard = null
		else:
			var prevCardIndex = currentLevel.layout.find(prevCard.info)
			var swapCardIndex = currentLevel.layout.find(board.lastSelectedCard.info)
			currentLevel.layout[swapCardIndex] = prevCard.info
			currentLevel.layout[prevCardIndex] = board.lastSelectedCard.info
			board.SetLayout(currentLevel.layout, cardEditScene)
			prevCard = null
	
func SaveLevel(level) -> void:
	var result = ResourceSaver.save("res://levels/level" + String(level.index) + ".tres", level, 0)
	assert(result == OK)
	fileDialog.invalidate()
	$Control/LevelLabel/LevelText.bbcode_text = "[center]res://levels/level" + String(currentLevel.index) + ".tres[/center]"
	
func LoadLevelInEditor(levelPath) -> void:
	currentLevel = ResourceLoader.load(levelPath)
	board.SetLayout(currentLevel.layout, cardEditScene)

	indexField.value = currentLevel.index
	setsToWinField.value = currentLevel.setsToWin
	timerField.value = currentLevel.timer
	shuffleToggle.pressed = currentLevel.shuffle
	$ModeOption.select(currentLevel.mode)
	$Control/LevelLabel/LevelText.bbcode_text = "[center]" + levelPath + "[/center]"
	var sets : Array = util.FindSets(currentLevel.layout)
	SetPreviewBoard(sets)

func SetPreviewBoard(sets) -> void:
	var setLayout : Array = []
	for set in sets:
		for info in set:
			setLayout.push_back(info)
	previewBoard.SetLayout(setLayout, cardScene)
	
func OnOpen():
	fileDialog.mode = FileDialog.MODE_OPEN_FILE
	fileDialog.popup()
	
func OnSave():
	if currentLevel:
		var file = File.new()
		if file.file_exists("res://levels/level" + String(currentLevel.index) + ".dat"):
			saveConfirmation.popup()
		else:
			SaveLevel(currentLevel)

func OnSaveConfirmation():
	SaveLevel(currentLevel)
	
func OnFileSelect(path):
	match $Control/FileDialog.mode:
		FileDialog.MODE_OPEN_FILE:
			LoadLevelInEditor(path)

func OnIndexChanged(value):
	currentLevel.index = value
	
func OnSetsToWinChanged(value):
	currentLevel.setsToWin = value
	
func OnNumCardsChanged(value):
	genNumCards = value
		
func OnNumSetsChanged(value):
	genSets = value
	
func OnGeneration():
	var sets : Array = []
	while sets.size() != genSets:
		var deck : Array = util.CreateDeck()
		currentLevel.layout = util.DrawFromDeck(deck, genNumCards)
		sets.clear()
		sets = util.FindSets(currentLevel.layout)
	board.SetLayout(currentLevel.layout, cardEditScene)
	SetPreviewBoard(sets)

func OnTimerChanged(value):
	currentLevel.timer = value

func OnShuffleToggle(button_pressed):
	currentLevel.shuffle = button_pressed

func _on_ModeOption_item_selected(index):
	currentLevel.mode = index

func _on_RefreshButton_pressed():
	var sets = util.FindSets(currentLevel.layout)
	SetPreviewBoard(sets)
