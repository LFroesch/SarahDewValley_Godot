extends Node

signal give_crop_seeds
signal feed_the_chickens
signal feed_the_cows
signal buy_egg
signal buy_milk
signal sell_logs
signal sell_stones

func action_give_crop_seeds() -> void:
	give_crop_seeds.emit()
	
func action_feed_cows() -> void:
	feed_the_cows.emit()

func action_feed_chickens() -> void:
	feed_the_chickens.emit()

func action_buy_egg() -> void:
	buy_egg.emit()

func action_buy_milk() -> void:
	buy_milk.emit()

func action_sell_logs() -> void:
	sell_logs.emit()

func action_sell_stones() -> void:
	sell_stones.emit()
