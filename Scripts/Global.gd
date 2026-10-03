extends Node

var fuel: float = 500 # reach 1000 to win
var depletionRate: int = 5
var fishCaught: Array = []
var heldFish: bool = false
var draining: bool = false


func _process(delta: float) -> void:
	if draining:
		fuel -= delta * depletionRate
	print(fuel)
