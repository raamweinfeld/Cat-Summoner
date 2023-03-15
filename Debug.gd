extends Control

onready var game = get_tree().root.get_node("Main")

func _process(delta):
	if Input.is_action_just_pressed("Debug_Solve"):
		game.Victory()
		
	if Input.is_action_just_pressed("Debug_NextLevel"):
		game.GoToLevel(game.currentLevel.index + 1)
	if Input.is_action_just_pressed("Debug_PreviousLevel"):
		game.GoToLevel(game.currentLevel.index - 1)
		
	$HintTimerText.text = "Hint Timer: " + str(int(game.get_node("HintTimer").time_left))
