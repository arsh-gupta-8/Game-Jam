extends Label


func _process(_delta: float) -> void:
	text = str(Global.fishCaught.size()) + " Fish Remaining"
	if Global.heldFish:
		text += "\n(Holding fish)"
