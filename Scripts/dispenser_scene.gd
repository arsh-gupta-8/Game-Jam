extends Node2D

const DROP_DISTANCE := 300.0   # how far the fish falls, in pixels
const DROP_TIME := 0.8
const FADE_OUT_TIME := 0.3

const SCARE_FUEL_LOSS := 100
const SCARE_DEPTH_CHANGE := -100.0   # see the note below about the sign

@onready var fish_drop: Node2D = $FishDrop
@onready var drop_body: Sprite2D = $FishDrop/Body
@onready var drop_spot: Sprite2D = $FishDrop/Spot

var busy := false
var start_pos: Vector2

const MIN_DEPTH := 0.0

func _ready() -> void:
	start_pos = fish_drop.position
	fish_drop.visible = false


func _process(_delta: float) -> void:
	if busy or Jumpscares.playing:
		return
	if Input.is_action_just_pressed("ui_accept") and (Global.current % 4) == 1:
		if not Global.heldFish and not Global.fishCaught.is_empty():
			take_next_fish()


func take_next_fish() -> void:
	busy = true
	Global.scene_locked = true
	var entry: Dictionary = Global.fishCaught.pop_front()
	var infected: bool = entry["infected"]

	drop_body.texture = entry["body_texture"]
	drop_spot.texture = entry["spot_texture"]
	drop_spot.visible = infected

	fish_drop.position = start_pos
	fish_drop.modulate.a = 0.0
	fish_drop.visible = true

	var tween := create_tween()
	tween.tween_property(fish_drop, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(fish_drop, "position:y", start_pos.y + DROP_DISTANCE, DROP_TIME)
	if not infected:
		tween.tween_property(fish_drop, "modulate:a", 0.0, FADE_OUT_TIME)
	await tween.finished

	if infected:
		Global.fuel = max(Global.fuel - SCARE_FUEL_LOSS, 0)
		Global.depth = max(Global.depth + SCARE_DEPTH_CHANGE, MIN_DEPTH)
		await Jumpscares.play()
	else:
		Global.heldFish = true
		Global.heldFuel = entry["fuel"]

	fish_drop.visible = false
	busy = false
	Global.scene_locked = false
