extends TextureButton
class_name Card

var info : CardInfo
var tile = 50
var rowsPerColor = 3
var atlas : AtlasTexture = AtlasTexture.new()
var size : Vector2 = Vector2(1, 1)

signal card_selected(card)

func SetTexture(p_texture) -> void:
	atlas.atlas = p_texture

func SetInfo(p_info) -> void:
	info = p_info
	
	atlas.region = Rect2(tile * info.shape, (tile * rowsPerColor * info.color) + (tile * info.pattern), tile, tile)
	for icon in $CountContainer.get_children():
		icon.queue_free()
		$CountContainer.remove_child(icon)
	
	for i in info.count:
		var icon : TextureRect = TextureRect.new()
		icon.texture = atlas
		icon.expand = true
		icon.rect_min_size = icon.texture.get_size() * size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		$CountContainer.add_child(icon)
	$CountContainer.set_anchors_and_margins_preset(PRESET_CENTER, PRESET_MODE_MINSIZE, 0)

func SetSize(p_size) -> void:
	size = p_size
	rect_min_size = texture_normal.get_size() * size
	for icon in $CountContainer.get_children():
		icon.rect_min_size = icon.texture.get_size() * size
	$CountContainer.set_anchors_and_margins_preset(PRESET_CENTER, PRESET_MODE_MINSIZE, 0)
	var shape : RectangleShape2D = RectangleShape2D.new()
	shape.extents = $Area2D/CollisionShape2D.shape.extents * p_size
	$Area2D/CollisionShape2D.position = shape.extents
	$Area2D/CollisionShape2D.set_shape(shape)

func GetSize() -> Vector2:
	return texture_normal.get_size() * size

func _on_Card_pressed():
	emit_signal("card_selected", self)
