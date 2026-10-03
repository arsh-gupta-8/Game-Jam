extends Sprite2D

@export var top_y: float = 558      # smaller Y: spot at the TOP (depth at start)
@export var bottom_y: float = 701.0  # bigger Y: spot at the BOTTOM (depth at 0)


func _process(delta: float) -> void:
	var ratio = clamp(Global.depth / 950.0, 0.0, 1.0)
	position.y = lerp(bottom_y, top_y, ratio)
