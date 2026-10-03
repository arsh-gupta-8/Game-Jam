extends Polygon2D

@export var show_seconds: float = 10.0


func _process(delta: float) -> void:
	visible = Global.play_time < show_seconds
