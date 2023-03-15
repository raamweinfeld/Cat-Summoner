extends GridContainer
class_name Board

export var interactable : bool
export var offset : Vector2
export var size : Vector2 = Vector2.ONE
export var cardTexture : Texture
var lastSelectedCard : Card = null
var cardSelected : bool = false
	
func _ready():
	SetOffset(offset)
	
func SetOffset(p_offset) -> void:
	offset = p_offset
	add_constant_override("hseparation", offset.x)
	add_constant_override("vseparation", offset.y)
	
func SetLayout(layout, cardScene) -> void:
	for card in get_children():
		remove_child(card)
		card.queue_free()
		card.disconnect("card_selected", self, "on_card_selected")
	for i in layout.size():
		var card : Card = cardScene.instance()
		add_child(card)
		card.SetTexture(cardTexture)
		card.SetSize(size)
		card.SetInfo(layout[i])
		card.connect("card_selected", self, "on_card_selected")
		
func on_card_selected(card):
	lastSelectedCard = card
	cardSelected = true

func GetCard() -> Card:
	var spaceState = get_world_2d().direct_space_state
	var mousePos = get_global_mouse_position()
	var result = spaceState.intersect_point(mousePos, 1, [], 2147483647, true, true)
	var card : Card = null
	if result:
		if self == result[0].collider.get_parent().get_parent():
			card = result[0].collider.get_parent()
	return card
