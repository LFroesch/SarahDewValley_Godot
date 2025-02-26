extends Node

signal give_crop_seeds
signal feed_the_chickens
signal feed_the_cows
signal buy_egg(amount: int)
signal buy_milk(amount: int)
signal sell_logs
signal sell_stones
signal start_quest(quest: String)

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

func action_sell_logs() -> void:
	sell_logs.emit()

func action_sell_stones() -> void:
	sell_stones.emit()

func action_start_quest(quest: String = "default") -> void:
	start_quest.emit(quest)
