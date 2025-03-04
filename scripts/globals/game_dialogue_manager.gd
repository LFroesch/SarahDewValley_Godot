extends Node

signal give_crop_seeds
signal feed_the_chickens
signal feed_the_cows
signal buy_egg(amount: int)
signal buy_milk(amount: int)
signal sell_egg(amount: int)
signal sell_milk(amount: int)
signal sell_logs
signal sell_stones
signal start_quest(quest: String)
signal sell_corn(amount: int)
signal sell_tomato(amount: int)
signal start_sewer_run
signal complete_sewer_run

func action_give_crop_seeds() -> void:
	give_crop_seeds.emit()
	
func action_feed_cows() -> void:
	feed_the_cows.emit()

func action_feed_chickens() -> void:
	feed_the_chickens.emit()

func action_buy_egg(amount: int = 1) -> void:
	buy_egg.emit(amount)

func action_buy_milk(amount: int = 1) -> void:
	buy_milk.emit(amount)
	
func action_sell_egg(amount: int = 1) -> void:
	sell_egg.emit(amount)

func action_sell_milk(amount: int = 1) -> void:
	sell_milk.emit(amount)

func action_sell_logs() -> void:
	sell_logs.emit()

func action_sell_stones() -> void:
	sell_stones.emit()

func action_sell_corn(amount: int = 1) -> void:
	sell_corn.emit(amount)

func action_sell_tomato(amount: int = 1) -> void:
	sell_tomato.emit(amount)

func action_start_quest(quest: String = "default") -> void:
	start_quest.emit(quest)
	
func action_start_sewer_run() -> void:
	start_sewer_run.emit()
	
func action_complete_sewer_run() -> void:
	complete_sewer_run.emit()
