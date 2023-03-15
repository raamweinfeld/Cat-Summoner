extends Panel

func _ready():
	$ColorOption.add_item("ORANGE")
	$ColorOption.add_item("GREEN")
	$ColorOption.add_item("BLACK")
	
	$ShapeOption.add_item("ROUND")
	$ShapeOption.add_item("FLUFFY")
	$ShapeOption.add_item("SHARP")
	
	$PatternOption.add_item("FILL")
	$PatternOption.add_item("STRIPED")
	$PatternOption.add_item("EMPTY")
	
	$CountOption.add_item("1")
	$CountOption.add_item("2")
	$CountOption.add_item("3")

func _on_EditButton_pressed():
	$ColorOption.selected = get_parent().info.color
	$ShapeOption.selected = get_parent().info.shape
	$PatternOption.selected = get_parent().info.pattern
	$CountOption.selected = get_parent().info.count - 1
	visible = true

func _on_ApplyButton_pressed():
	visible = false
	get_parent().info.color = $ColorOption.selected
	get_parent().info.shape = $ShapeOption.selected
	get_parent().info.pattern = $PatternOption.selected
	get_parent().info.count = $CountOption.selected + 1
	get_parent().SetInfo(get_parent().info)
