extends Node

var fuel: float = 500 # reach 1000 to win
var depletionRate: int = 10
var fishCaught: Array = []
var heldFish: bool = false
var draining: bool = false
var depthStart: float = 950
var depth: float = 950
var depthDuration: float = 600  # seconds to sink to the bottom
var current := 0

func _process(delta: float) -> void:
	if draining:
		fuel -= delta * depletionRate
		depth = max(depth - delta * depthStart / depthDuration, 0.0)
		print(fuel)
