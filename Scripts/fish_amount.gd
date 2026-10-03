extends Label


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and (Global.current % 4) == 1:
		if not Global.heldFish and not Global.fishCaught.is_empty():
			Global.fishCaught.pop_front()
			Global.heldFish = true

	text = str(Global.fishCaught.size()) + " Fish Remaining"
	if Global.heldFish:
		text += "\n(Holding fish)"
