extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bio_sound: AudioStreamPlayer2D = $BioSound

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and Global.heldFish and (Global.current % 4) == 2:
		Global.heldFish = false
		Global.fuel += Global.heldFuel
		Global.heldFuel = 0
		animation_player.play("putwastein")
		bio_sound.play()
