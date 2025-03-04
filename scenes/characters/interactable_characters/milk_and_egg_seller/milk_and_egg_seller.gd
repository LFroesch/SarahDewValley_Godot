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
	
	GameDialogueManager.buy_egg.connect(on_buy_egg)
	GameDialogueManager.buy_milk.connect(on_buy_milk)
	GameDialogueManager.sell_egg.connect(on_sell_egg)
	GameDialogueManager.sell_milk.connect(on_sell_milk)
	
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
			active_balloon.start(load("res://dialogue/conversations/shop_starter_zone.dialogue"), "start_milk_and_egg_seller")
			
const BUY_PRICES = {
	"egg": 8,
	"milk": 10
}

const SELL_PRICES = {
	"egg": 4,
	"milk": 5
}

func buy_item(item_name: String, amount: int = 1) -> bool:
	var price = BUY_PRICES[item_name] * amount
	if not InventoryManager.inventory.has("coin") or InventoryManager.inventory["coin"] < price:
		return false
	for i in price:
		InventoryManager.remove_collectible("coin")
	for i in amount:
		InventoryManager.add_collectible(item_name)
	return true
	
func sell_item(item_name: String, amount: int = 1) -> bool:
	if not InventoryManager.inventory.has(item_name) or InventoryManager.inventory[item_name] <= 0:
		return false
	var actual_amount = min(amount, InventoryManager.inventory[item_name])
	var price = SELL_PRICES[item_name] * actual_amount
	for i in actual_amount:
		InventoryManager.remove_collectible(item_name)
	for i in price:
		InventoryManager.add_collectible("coin")
	return actual_amount > 0

func on_buy_egg(amount: int = 1) -> void:
	buy_item("egg", amount)

func on_buy_milk(amount: int = 1) -> void:
	buy_item("milk", amount)
	
func on_sell_egg(amount: int = 1) -> void:
	sell_item("egg", amount)

func on_sell_milk(amount: int = 1) -> void:
	sell_item("milk", amount)
