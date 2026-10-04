extends Node2D

const FUEL_PER_FISH := 20
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bio_sound: AudioStreamPlayer2D = $BioSound

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and Global.heldFish and (Global.current % 4) == 2:
		Global.heldFish = false
		Global.fuel += FUEL_PER_FISH
		animation_player.play("putwastein")
		bio_sound.play()
