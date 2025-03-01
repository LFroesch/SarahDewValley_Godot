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
	
	# Important: update the growth state immediately when loading
	if is_watered and starting_day > 0:
		# Wait one frame to ensure DayAndNightCycleManager has loaded
		await get_tree().process_frame
		simulate_growth_to_current_day()
	
func on_time_tick_day(day: int) -> void:
	if is_watered:
		if starting_day == 0:
			starting_day = day
		
		growth_states(starting_day, day)
		harvest_state(starting_day, day)

# New function to simulate growth when loading a saved crop
func simulate_growth_to_current_day() -> void:
	var day = DayAndNightCycleManager.current_day
	
	# Don't process if no growth has started
	if starting_day <= 0 or !is_watered:
		return
	
	# First update growth stages
	growth_states(starting_day, day)
	
	# Then check for harvest state
	harvest_state(starting_day, day)

func growth_states(starting_day: int, current_day: int):
	if current_growth_state == DataTypes.GrowthStates.Maturity or current_growth_state == DataTypes.GrowthStates.Harvesting:
		return
	
	var days_passed = current_day - starting_day
	if days_passed <= 0:
		return
	
	# Calculate appropriate growth state based on days passed
	var growth_days = min(days_until_harvest - 1, days_passed)  # Cap at one day before harvest
	var growth_states = DataTypes.GrowthStates.Maturity  # This gets the number of states
	var days_per_state = max(1, days_until_harvest / growth_states)
	
	var new_state = DataTypes.GrowthStates.Germination
	if days_passed >= days_per_state:
		# Calculate based on proportion of days passed
		new_state = min(DataTypes.GrowthStates.Maturity, 
					   DataTypes.GrowthStates.Germination + int(growth_days / days_per_state))
	
	# Update only if the state has changed
	if new_state != current_growth_state:
		current_growth_state = new_state
		
		if current_growth_state == DataTypes.GrowthStates.Maturity:
			crop_maturity.emit()

func harvest_state(starting_day: int, current_day: int):
	if current_growth_state == DataTypes.GrowthStates.Harvesting:
		return
		
	var days_passed = current_day - starting_day
	
	if days_passed >= days_until_harvest:
		current_growth_state = DataTypes.GrowthStates.Harvesting
		crop_harvesting.emit()

func get_current_growth_state() -> DataTypes.GrowthStates:
	return current_growth_state
