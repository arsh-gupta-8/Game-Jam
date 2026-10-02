extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and not Global.fishCaught.is_empty():
		var removed = Global.fishCaught.pop_front()
		print("Removed: ", removed)

	text = str(Global.fishCaught.size()) + " Fish Remaining"
