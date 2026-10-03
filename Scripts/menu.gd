extends Node2D

const NEXT_SCENE = "res://Scenes/main.tscn"

@onready var prompt_label: Label = $Label

var starting := false

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(prompt_label, "modulate:a", 0.2, 0.8)
	tween.tween_property(prompt_label, "modulate:a", 1.0, 0.8)


func _unhandled_input(event: InputEvent) -> void:
	if starting:
		return
	var pressed_key = event is InputEventKey and event.pressed and not event.echo
	var pressed_click = event is InputEventMouseButton and event.pressed
	if pressed_key or pressed_click:
		starting = true
		get_tree().change_scene_to_file(NEXT_SCENE)
