extends PanelContainer
class_name TalentsMenu

var player: Player

const SPEED_PER_LEVEL: float = 8.0
const HEALTH_PER_LEVEL: float = 10.0
const FIREBALL_DAMAGE_PER_LEVEL: float = 5.0
const FIRE_NOVA_DAMAGE_PER_LEVEL: float = 7.0
const HEAL_AMOUNT_PER_LEVEL: float = 10.0
const MELEE_DAMAGE_PER_LEVEL: float = 5.0

@onready var available_points_label: Label = $MarginContainer/VBoxContainer/AvailablePointsLabel
@onready var health_counter: Label = $MarginContainer/VBoxContainer/HealthRow/Counter
@onready var health_value: Label = $MarginContainer/VBoxContainer/HealthRow/Value
@onready var speed_counter: Label = $MarginContainer/VBoxContainer/SpeedRow/Counter
@onready var speed_value: Label = $MarginContainer/VBoxContainer/SpeedRow/Value
@onready var fireball_counter: Label = $MarginContainer/VBoxContainer/FireballRow/Counter
@onready var fireball_value: Label = $MarginContainer/VBoxContainer/FireballRow/Value
@onready var fire_nova_counter: Label = $MarginContainer/VBoxContainer/FireNovaRow/Counter
@onready var fire_nova_value: Label = $MarginContainer/VBoxContainer/FireNovaRow/Value
@onready var heal_counter: Label = $MarginContainer/VBoxContainer/HealRow/Counter
@onready var heal_value: Label = $MarginContainer/VBoxContainer/HealRow/Value
@onready var melee_counter: Label = $MarginContainer/VBoxContainer/MeleeRow/Counter
@onready var melee_value: Label = $MarginContainer/VBoxContainer/MeleeRow/Value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_talents_menu"):
		visible = !visible
		if visible:
			update_ui()
			_find_player()

var has_initialized: bool = false
var player_finder_timer: Timer

func _ready() -> void:
	hide()
	update_ui()
	StatisticsManager.level_up.connect(_on_level_up)
	StatisticsManager.talent_point_added.connect(_on_talent_point_added)
	StatisticsManager.talent_spent.connect(_on_talent_spent)
	StatisticsManager.talents_reset.connect(_on_talents_reset)
	#StatisticsManager.add_talent_points(10)
	initialize_ui_values()
	player_finder_timer = Timer.new()
	player_finder_timer.wait_time = 0.5
	player_finder_timer.one_shot = false
	player_finder_timer.timeout.connect(_find_player)
	add_child(player_finder_timer)
	player_finder_timer.start()
	_find_player()
	
func _find_player() -> void:
	var found_player = get_tree().get_first_node_in_group("player") as Player
	if found_player != null:
		player = found_player
		if not has_initialized:
			apply_all_talents()
			has_initialized = true
		player_finder_timer.stop()
	else:
		print("Will try to find player again")

func initialize_ui_values() -> void:
	available_points_label.text = "Available Talent Points: %d" % StatisticsManager.get_available_talent_points()
	
	var health_level = StatisticsManager.get_talent_level("health")
	var speed_level = StatisticsManager.get_talent_level("speed")
	var fireball_level = StatisticsManager.get_talent_level("fireball")
	var fire_nova_level = StatisticsManager.get_talent_level("fire_nova")
	var heal_level = StatisticsManager.get_talent_level("heal")
	var melee_level = StatisticsManager.get_talent_level("melee")
	
	health_counter.text = "Pts: %d" % health_level
	health_value.text = "Health: %.1f" % (100.0 + (health_level * HEALTH_PER_LEVEL))
	
	speed_counter.text = "Pts: %d" % speed_level
	speed_value.text = "Speed: %.1f" % get_speed(speed_level)
	
	fireball_counter.text = "Pts: %d" % fireball_level
	fireball_value.text = "Fireball: %.1f dmg" % get_fireball_damage(fireball_level)
	
	fire_nova_counter.text = "Pts: %d" % fire_nova_level
	fire_nova_value.text = "Fire Nova: %.1f dmg" % get_fire_nova_damage(fire_nova_level)
	
	heal_counter.text = "Pts: %d" % heal_level
	heal_value.text = "Heal: %.1f hp" % get_heal_amount(heal_level)
	
	melee_counter.text = "Pts: %d" % melee_level
	melee_value.text = "Melee: %.1f dmg" % get_melee_damage(melee_level)

func update_ui() -> void:
	if not player:
		return
		
	available_points_label.text = "Available Talent Points: %d" % StatisticsManager.get_available_talent_points()
	
	var health_level = StatisticsManager.get_talent_level("health")
	var speed_level = StatisticsManager.get_talent_level("speed")
	var fireball_level = StatisticsManager.get_talent_level("fireball")
	var fire_nova_level = StatisticsManager.get_talent_level("fire_nova")
	var heal_level = StatisticsManager.get_talent_level("heal")
	var melee_level = StatisticsManager.get_talent_level("melee")
	
	health_counter.text = "Pts: %d" % health_level
	health_value.text = "Health: %.1f" % player.max_health
	
	speed_counter.text = "Pts: %d" % speed_level
	speed_value.text = "Speed: %.1f" % [
		get_speed(speed_level)
	]
	
	fireball_counter.text = "Pts: %d" % fireball_level
	fireball_value.text = "Fireball: %.1f dmg" % [
		get_fireball_damage(fireball_level)
	]
	
	fire_nova_counter.text = "Pts: %d" % fire_nova_level
	fire_nova_value.text = "Fire Nova: %.1f dmg" % [
		get_fire_nova_damage(fire_nova_level)
	]
	
	heal_counter.text = "Pts: %d" % heal_level
	heal_value.text = "Heal: %.1f hp" % [
		get_heal_amount(heal_level)
	]
	
	melee_counter.text = "Pts: %d" % melee_level
	melee_value.text = "Melee: %.1f dmg" % get_melee_damage(melee_level)

func get_speed(level: int) -> float:
	var base_speed = 48
	return base_speed + (level * SPEED_PER_LEVEL)

func get_fireball_damage(level: int) -> float:
	var base_damage = 35 
	return base_damage + (level * FIREBALL_DAMAGE_PER_LEVEL)
	
func get_fire_nova_damage(level: int) -> float:
	var base_damage = 40 
	return base_damage + (level * FIRE_NOVA_DAMAGE_PER_LEVEL)
	
func get_heal_amount(level: int) -> float:
	var base_heal = 20 
	return base_heal + (level * HEAL_AMOUNT_PER_LEVEL)
	
func get_melee_damage(level: int) -> float:
	var base_damage = 25
	return base_damage + (level * MELEE_DAMAGE_PER_LEVEL)

func _on_health_increment_pressed() -> void:
	if StatisticsManager.get_available_talent_points() > 0:
		var new_level = StatisticsManager.get_talent_level("health") + 1
		StatisticsManager.update_talent("health", new_level)
		player.max_health += HEALTH_PER_LEVEL
		update_ui()

func _on_speed_increment_pressed() -> void:
	if StatisticsManager.get_available_talent_points() > 0:
		var new_level = StatisticsManager.get_talent_level("speed") + 1
		StatisticsManager.update_talent("speed", new_level)
		update_ui()

func _on_fireball_increment_pressed() -> void:
	if StatisticsManager.get_available_talent_points() > 0:
		var new_level = StatisticsManager.get_talent_level("fireball") + 1
		StatisticsManager.update_talent("fireball", new_level)
		update_ui()

func _on_fire_nova_increment_pressed() -> void:
	if StatisticsManager.get_available_talent_points() > 0:
		var new_level = StatisticsManager.get_talent_level("fire_nova") + 1
		StatisticsManager.update_talent("fire_nova", new_level)
		update_ui()

func _on_heal_increment_pressed() -> void:
	if StatisticsManager.get_available_talent_points() > 0:
		var new_level = StatisticsManager.get_talent_level("heal") + 1
		StatisticsManager.update_talent("heal", new_level)
		update_ui()

func _on_melee_increment_pressed() -> void:
	if StatisticsManager.get_available_talent_points() > 0:
		var new_level = StatisticsManager.get_talent_level("melee") + 1
		StatisticsManager.update_talent("melee", new_level)
		update_ui()

# Apply all talents to player (called on game load)
func apply_all_talents() -> void:
	if not player:
		return

	var health_level = StatisticsManager.get_talent_level("health")
	var speed_level = StatisticsManager.get_talent_level("speed")
	var fireball_level = StatisticsManager.get_talent_level("fireball")
	var fire_nova_level = StatisticsManager.get_talent_level("fire_nova")
	var heal_level = StatisticsManager.get_talent_level("heal")
	var melee_level = StatisticsManager.get_talent_level("melee")
	
	# Apply health bonus
	player.max_health = 100.0 + (health_level * HEALTH_PER_LEVEL)
	
func _on_reset_button_pressed() -> void:
	StatisticsManager.reset_talents()
	
	# Reset player stats to base values
	player.max_health = 100.0
	update_ui()

# Signal Handlers
func _on_level_up(_new_level: int) -> void:
	if visible:
		update_ui()

func _on_talent_point_added(_amount: int) -> void:
	if visible:
		update_ui()

func _on_talent_spent(_talent_name: String, _level: int) -> void:
	if visible:
		update_ui()

func _on_talents_reset() -> void:
	if visible:
		update_ui()
