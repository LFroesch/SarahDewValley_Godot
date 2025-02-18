extends Node

signal give_crop_seeds
signal feed_the_chickens
signal feed_the_cows

func action_give_crop_seeds() -> void:
	give_crop_seeds.emit()
	
func action_feed_cows() -> void:
	feed_the_cows.emit()

func action_feed_chickens() -> void:
	feed_the_chickens.emit()
