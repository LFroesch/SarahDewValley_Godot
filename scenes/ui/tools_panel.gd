extends PanelContainer
@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering_can: Button = $MarginContainer/HBoxContainer/ToolWateringCan
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato
@onready var fireball_texture: TextureRect = $MarginContainer/HBoxContainer/FireballTexture
@onready var nova_texture: TextureRect = $MarginContainer/HBoxContainer/NovaTexture
@onready var holy_nova_texture: TextureRect = $MarginContainer/HBoxContainer/HolyNovaTexture

@onready var fireball_timer_label: Label = null
@onready var nova_timer_label: Label = null
@onready var holy_nova_timer_label: Label = null

var player: Player = null
var is_combat_mode: bool = false

func _ready() -> void:
	ToolManager.enable_tool.connect(on_enable_tool_button)
	ToolManager.tools_reset.connect(on_tools_reset)
	
	# Initialize tools as disabled (except axe which works in both modes)
	tool_tilling.disabled = true
	tool_tilling.focus_mode = Control.FOCUS_NONE
	
	tool_watering_can.disabled = true
	tool_watering_can.focus_mode = Control.FOCUS_NONE
	
	tool_corn.disabled = true
	tool_corn.focus_mode = Control.FOCUS_NONE
	
	tool_tomato.disabled = true
	tool_tomato.focus_mode = Control.FOCUS_NONE
	
	fireball_timer_label = create_timer_label(fireball_texture)
	nova_timer_label = create_timer_label(nova_texture)
	holy_nova_timer_label = create_timer_label(holy_nova_texture)
	
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	fireball_texture.gui_input.connect(_on_fireball_texture_input)
	nova_texture.gui_input.connect(_on_nova_texture_input)
	holy_nova_texture.gui_input.connect(_on_holy_nova_texture_input)
	
	# Make sure the toolbar is in the right state initially
	update_toolbar_visibility()
	
func create_timer_label(parent_texture: TextureRect) -> Label:
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var position_offset = Vector2(-1, -2)
	label.position += position_offset
	var font = load("res://assets/ui/fonts/zx_palm_variation.tres")
	label.add_theme_font_override("font", font)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent_texture.add_child(label)
	
	return label

func _process(delta: float) -> void:
	if player:
		update_ability_displays()

func update_ability_displays() -> void:
	if player.can_shoot:
		fireball_texture.modulate = Color(1, 1, 1, 1)
		fireball_timer_label.text = ""
	else:
		fireball_texture.modulate = Color(0.5, 0.5, 0.5, 1)
		fireball_timer_label.text = str(ceil(player.shoot_timer.time_left))
	
	if player.can_cast_nova:
		nova_texture.modulate = Color(1, 1, 1, 1)
		nova_timer_label.text = ""
	else:
		nova_texture.modulate = Color(0.5, 0.5, 0.5, 1)
		nova_timer_label.text = str(ceil(player.fire_nova_timer.time_left))
		
	if player.can_cast_heal:
		holy_nova_texture.modulate = Color(1,1,1,1)
		holy_nova_timer_label.text = ""
	else:
		holy_nova_texture.modulate = Color(0.5, 0.5, 0.5, 1)
		holy_nova_timer_label.text = str(ceil(player.heal_timer.time_left))

func _on_fireball_texture_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player and player.can_shoot:
			player.shoot_fireball()

func _on_nova_texture_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player and player.can_cast_nova:
			player.cast_fire_nova()

func _on_holy_nova_texture_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player and player.can_cast_heal:
			player.cast_heal()

func _on_tool_axe_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.AxeWood)

func _on_tool_tilling_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.TillGround)

func _on_tool_watering_can_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.WaterCrops)

func _on_tool_corn_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.PlantCorn)

func _on_tool_tomato_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.PlantTomato)

func _unhandled_input(event: InputEvent) -> void:
	# Check for swap_toolbar input
	if event.is_action_pressed("swap_toolbar"):
		# Toggle between combat and farming mode
		is_combat_mode = !is_combat_mode
		update_toolbar_visibility()
		
		# When switching to farming mode, select the first available farming tool
		if !is_combat_mode:
			if !tool_tilling.disabled:
				ToolManager.select_tool(DataTypes.Tools.TillGround)
			elif !tool_watering_can.disabled:
				ToolManager.select_tool(DataTypes.Tools.WaterCrops)
			elif !tool_corn.disabled:
				ToolManager.select_tool(DataTypes.Tools.PlantCorn)
			elif !tool_tomato.disabled:
				ToolManager.select_tool(DataTypes.Tools.PlantTomato)
		else:
			# When switching to combat mode, deselect any farming tools
			ToolManager.select_tool(DataTypes.Tools.AxeWood)
	
func update_toolbar_visibility() -> void:
	# Combat mode: Show combat abilities, hide farming tools (except axe)
	if is_combat_mode:
		# Show combat abilities
		fireball_texture.visible = true
		nova_texture.visible = true
		holy_nova_texture.visible = true
		
		# Hide farming tools (except axe which works in both modes)
		tool_tilling.visible = false
		tool_watering_can.visible = false
		tool_corn.visible = false
		tool_tomato.visible = false
	else:
		# Farming mode: Hide combat abilities, show farming tools
		fireball_texture.visible = false
		nova_texture.visible = false
		holy_nova_texture.visible = false
		
		# Show farming tools (they'll still be disabled until unlocked)
		tool_tilling.visible = true
		tool_watering_can.visible = true
		tool_corn.visible = true
		tool_tomato.visible = true
	
func on_enable_tool_button(tool: DataTypes.Tools) -> void:
	if tool == DataTypes.Tools.TillGround:
		tool_tilling.disabled = false
		tool_tilling.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.WaterCrops:
		tool_watering_can.disabled = false
		tool_watering_can.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.PlantCorn:
		tool_corn.disabled = false
		tool_corn.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.PlantTomato:
		tool_tomato.disabled = false
		tool_tomato.focus_mode = Control.FOCUS_ALL

func on_tools_reset() -> void:
	# Disable all farming tools
	tool_tilling.disabled = true
	tool_tilling.focus_mode = Control.FOCUS_NONE
	
	tool_watering_can.disabled = true
	tool_watering_can.focus_mode = Control.FOCUS_NONE
	
	tool_corn.disabled = true
	tool_corn.focus_mode = Control.FOCUS_NONE
	
	tool_tomato.disabled = true
	tool_tomato.focus_mode = Control.FOCUS_NONE
	
	# Switch to combat mode
	is_combat_mode = true
	update_toolbar_visibility()
