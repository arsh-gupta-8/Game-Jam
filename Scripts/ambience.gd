extends AudioStreamPlayer2D

func _ready() -> void:
	finished.connect(play)

func start() -> void:
	if not playing:
		play()
