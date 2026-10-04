extends CanvasLayer

const SCENES: Array[PackedScene] = [
	preload("res://Scenes/jumpscare_1.tscn"),
	preload("res://Scenes/jumpscare_2.tscn"),
	preload("res://Scenes/jumpscare_3.tscn"),
	preload("res://Scenes/jumpscare_4.tscn"),
]

var playing := false

func _ready() -> void:
	layer = 100   # draws above everything

func play() -> void:
	if playing:
		return
	playing = true
	var scare: Node = SCENES.pick_random().instantiate()
	add_child(scare)
	var anim: AnimationPlayer = scare.get_node("AnimationPlayer")
	anim.play("scare")
	await anim.animation_finished
	scare.queue_free()
	playing = false
