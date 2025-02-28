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
	GameDialogueManager.start_quest.connect(on_start_quest_from_dialogue)
	
func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true
	var npc_id = "sam"
	QuestManager.record_npc_interaction(npc_id)
	
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
			active_balloon.start(load("res://dialogue/conversations/sewer_sam.dialogue"), "sewer_sam_entrance")

func on_start_quest(quest: String) -> void:
	QuestManager.start_quest(quest)
	
func on_start_quest_from_dialogue(quest: String) -> void:
	QuestManager.start_quest(quest)
