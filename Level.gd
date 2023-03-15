extends Resource
class_name Level

enum Mode { TUTORIAL, FIXED }

export var layout : Array
export var setsToWin : int
export var index : int
export var timer : int
export var shuffle : bool
export var mode : int

func _init(p_layout = [], p_setsToWin = 1, p_index = 0, p_timer = 0, p_shuffle = false):
	layout = p_layout
	setsToWin = p_setsToWin
	index = p_index
	timer = p_timer
	shuffle = p_shuffle
