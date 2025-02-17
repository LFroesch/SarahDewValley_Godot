class_name GrowthCycleComponent
extends Node

@export var current_growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Germination
@export_range(4, 365) var days_until_harvest: int = 4

signal crop_maturity
signal crop_harvesting

var is_watered: bool:
	set(value):
		is_watered = value
		if value == true and starting_day == 0:
			starting_day = DayAndNightCycleManager.current_day
var starting_day: int
var current_day: int

func _ready() -> void:
	DayAndNightCycleManager.time_tick_day.connect(on_time_tick_day)
	
func on_time_tick_day(day: int) -> void:
	if is_watered:
		if starting_day == 0:
			starting_day = day
		
		growth_states(starting_day, day)
		harvest_state(starting_day, day)
			
@warning_ignore("shadowed_variable")
func growth_states(starting_day: int, current_day: int):
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		return
	
	var num_states = 5
	var growth_days_passed = (current_day - starting_day) % num_states
	var state_index = growth_days_passed % num_states + 1
	
	
	@warning_ignore("int_as_enum_without_cast")
	current_growth_state = state_index
	
	@warning_ignore("unused_variable", "shadowed_variable_base_class")
	var name = DataTypes.GrowthStates.keys()[current_growth_state]
	
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		crop_maturity.emit()

@warning_ignore("shadowed_variable")
func harvest_state(starting_day: int, current_day: int):
	if current_growth_state == DataTypes.GrowthStates.Harvesting:
		return
	var days_passed = (current_day - starting_day)
	
	if days_passed >= days_until_harvest:
		current_growth_state = DataTypes.GrowthStates.Harvesting
		crop_harvesting.emit()

func get_current_growth_state() -> DataTypes.GrowthStates:
	return current_growth_state
