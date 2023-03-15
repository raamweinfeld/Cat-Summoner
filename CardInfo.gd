extends Resource
class_name CardInfo

enum IconColor {ORANGE, GREY, BLACK}
export var color : int

enum IconShape {ROUND, FLUFFY, SHARP}
export var shape : int

enum IconPattern {FILL, STRIPED, EMPTY}
export var pattern : int
	
export var count : int

func _init(p_color = 0, p_shape = 0, p_pattern = 0, p_count = 1):
	color = p_color
	shape = p_shape
	pattern = p_pattern
	count = p_count
