extends Node2D

var util : GameUtil = GameUtil.new()

onready var catList = $Screen/Sidebar/CatList
onready var catName = $Screen/MainPanel/CatNameLabel/CatName
onready var catRarity = $Screen/MainPanel/CatRarityLabel/CatRarity
onready var imageDialog = $Screen/MainPanel/ImageDialog
onready var catImageBrowse = $Screen/MainPanel/CatImageLabel/CatImageBrowse
onready var catSummon = $Screen/MainPanel/Altar/Summon
onready var catStory = $Screen/MainPanel/CatStoryLabel/CatStory

var noCatIcon : Texture = preload("res://tools/missing_cat.png")

var catData : CatList
var catIndex : int = -1

func _ready():
	catList.set_fixed_icon_size(Vector2(64, 64))
	
	catRarity.add_item("COMMON", 0)
	catRarity.add_item("UNCOMMON", 1)
	catRarity.add_item("RARE", 2)
	catRarity.add_item("LEGENDARY", 3)
	
	catData = ResourceLoader.load("res://data/cat_list.tres")
	if catData:
		for cat in catData.list:
			CreateCatListItem(cat)
	else:
		catData = CatList.new()

func CreateCatListItem(cat) -> void:
	catList.add_item(cat.name, null)
	var image : Texture = null
	if cat.summonImagePath:
		image = load(cat.summonImagePath)
	if image:
		catList.set_item_icon(catList.get_item_count() - 1, image)
	else:
		catList.set_item_icon(catList.get_item_count() - 1, noCatIcon)

func _process(delta):
	if Input.is_action_just_pressed("Delete"):
		if catIndex != -1:
			catList.remove_item(catIndex)
			catData.remove(catIndex)
			catIndex -= 1
			catList.select(catIndex)
			UpdateCatData(catIndex)

func UpdateCatData(index) -> void:
	if index > -1:
		var cat = catData.list[index]
		catName.text = cat.name
		catRarity.select(cat.rarity)
		var image = null
		if cat.summonImagePath:
			image = load(cat.summonImagePath)
		if image:
			catList.set_item_icon(index, image)
			catSummon.texture = image
			catImageBrowse.text = cat.summonImagePath
		else:
			catImageBrowse.text = "..."
		catStory.text = cat.story

func _on_AddButton_pressed():
	catData.list.push_back(Cat.new())
	catList.add_item(catData.list[catData.list.size() - 1].name, noCatIcon)
	catList.select(catData.list.size() - 1)
	catIndex = catData.list.size() - 1
	UpdateCatData(catIndex)
	
func _on_CatList_item_selected(index):
	catIndex = index
	UpdateCatData(catIndex)

func _on_CatName_text_changed(new_text):
	catData.list[catIndex].name = new_text
	catList.set_item_text(catIndex, new_text)

func _on_CatRarity_item_selected(index):
	catData.list[catIndex].rarity = index

func _on_CatImageBrowse_pressed():
	imageDialog.popup()

func _on_ImageDialog_file_selected(path):
	catData.list[catIndex].summonImagePath = path
	var image = load(catData.list[catIndex].summonImagePath)
	if image:
			catList.set_item_icon(catIndex, image)
			catSummon.texture = image
			catImageBrowse.text = catData.list[catIndex].summonImagePath

func _on_CatStory_focus_exited():
	catData.list[catIndex].story = catStory.text

func _on_Save_pressed():
	ResourceSaver.save("res://data/cat_list.tres", catData)
