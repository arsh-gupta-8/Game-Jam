extends Sprite2D

@export var top_y: float = 539       # smaller Y: spot at the TOP (fuel full)
@export var bottom_y: float = 759.0  # bigger Y: spot at the BOTTOM (fuel empty)


func _process(delta: float) -> void:
	var ratio = clamp(Global.fuel / 1000.0, 0.0, 1.0)
	position.y = lerp(bottom_y, top_y, ratio)
