extends Node

var fuel: float = 500 # reach 1000 to win
var depletionRate: int = 2
var fishCaught: Array = []
var heldFish: bool = false
var heldFuel: int = 0
var draining: bool = false
var depthStart: float = 950
var depth: float = 950
var depthDuration: float = 360  # seconds to sink to the bottom
var current := 0
var play_time: float = 0.0
var scene_locked := false

func _process(delta: float) -> void:
	
	if draining:
		play_time += delta
		fuel -= delta * depletionRate
		depth = max(depth - delta * depthStart / depthDuration, 0.0)
