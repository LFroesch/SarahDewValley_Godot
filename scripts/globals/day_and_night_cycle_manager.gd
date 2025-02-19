extends Node
class_name TimeManager

const MINUTES_PER_DAY: int = 24 * 60
const MINUTES_PER_HOUR: int = 60
const GAME_MINUTE_DURATION: float = TAU / MINUTES_PER_DAY

var game_speed: float = 2.5

var initial_day: int = 1
var initial_hour: int = 8
var initial_minute: int = 30

var time: float = 0.0
var current_minute: int = -1
var current_day: int = 0

signal game_time(time: float)
signal time_tick(day: int, hour: int, minute: int)
@warning_ignore("unused_signal")
signal time_tick_day(day: int)

func _ready() -> void:
	set_initial_time()
		
func _process(delta: float) -> void:
	time += delta * game_speed * GAME_MINUTE_DURATION
	game_time.emit(time)
	recalculate_time()

func set_initial_time() -> void:
	var initial_total_minutes = initial_day * MINUTES_PER_DAY + (initial_hour * MINUTES_PER_HOUR) + initial_minute
	time = initial_total_minutes * GAME_MINUTE_DURATION

func recalculate_time() -> void:
	var total_minutes: int = int(time / GAME_MINUTE_DURATION)
	@warning_ignore("integer_division")
	var day: int = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes: int = total_minutes % MINUTES_PER_DAY
	@warning_ignore("integer_division")
	var hour: int = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute: int = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if current_minute != minute:
		current_minute = minute
		time_tick.emit(day, hour, minute)
		
	if current_day != day:
		current_day = day
		time_tick_day.emit(day)
		
var save_data_path: String = "user://game_data/time_data.tres"

# Add to Crop States as well
func save_time_state() -> void:
	var time_data = {
		"time": time,
		"current_minute": current_minute,
		"current_day": current_day,
		"game_speed": game_speed,
		"initial_day": initial_day,
		"initial_hour": initial_hour,
		"initial_minute": initial_minute
		}
	
	var save_resource = Resource.new()
	save_resource.set_meta("time_data", time_data)
	var result = ResourceSaver.save(save_resource, save_data_path)
	print("Time save result: ", result)

func load_time_state() -> void:
	if not FileAccess.file_exists(save_data_path):
		return
		
	var save_resource = ResourceLoader.load(save_data_path)
	if save_resource and save_resource.has_meta("time_data"):
		var time_data = save_resource.get_meta("time_data")
		time = time_data.time
		current_minute = time_data.current_minute
		current_day = time_data.current_day
		game_speed = time_data.game_speed
		initial_day = time_data.initial_day
		initial_hour = time_data.initial_hour
		initial_minute = time_data.initial_minute
		
		# Emit signals to update any listeners
		game_time.emit(time)
		recalculate_time()
