extends Node

onready var cardScenePath : String = "res://Card.tscn"
onready var cardTexturePath : String = "res://icons.png"

onready var cardOffset : Vector2 = Vector2(3, 5)

onready var lockedCats : Array = []
onready var unlockedCats : Array = []
