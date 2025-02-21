extends Node2D

var balloon_scene = preload("res://dialogue/game_dialogue_balloon.tscn")

@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var interactable_component: InteractableComponent = $InteractableComponent

var in_range: bool
var active_balloon: BaseGameDialogueBalloon = null

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()
	
	GameDialogueManager.sell_logs.connect(on_sell_logs)
	GameDialogueManager.sell_stones.connect(on_sell_stones)
	
	
func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true
	
func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false
	
	if is_instance_valid(active_balloon):
		active_balloon.queue_free()
	active_balloon = null

func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			if is_instance_valid(active_balloon):
				active_balloon.queue_free()
			active_balloon = balloon_scene.instantiate()
			get_tree().root.add_child(active_balloon) 
			active_balloon.start(load("res://dialogue/conversations/shop_starter_zone.dialogue"), "start_stone_and_log_buyer")
			
const ITEM_PRICES = {
	"log": 3,
	"stone": 5
}
func sell_item(item_name: String) -> bool:
	if !InventoryManager.inventory.has(item_name):
		return false
	var price = ITEM_PRICES[item_name]
	var inventory_item_count = InventoryManager.inventory[item_name]
	var items_to_sell = mini(inventory_item_count, 5)
	
	for i in items_to_sell:
		for j in price:
			InventoryManager.add_collectible("coin")
		InventoryManager.remove_collectible(item_name)
	return true

func on_sell_logs() -> void:
	sell_item("log")

func on_sell_stones() -> void:
	sell_item("stone")
