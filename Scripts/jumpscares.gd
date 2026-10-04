extends CanvasLayer

const SCENES: Array[PackedScene] = [
	preload("res://Scenes/jumpscare_1.tscn"),
	preload("res://Scenes/jumpscare_2.tscn"),
	preload("res://Scenes/jumpscare_3.tscn"),
	preload("res://Scenes/jumpscare_4.tscn"),
]

const FADE_OUT_TIME := 1   # fish and black fade out together at the very end

var playing := false


func _ready() -> void:
	layer = 100


func play() -> void:
	if playing:
		return
	playing = true

	# holder keeps the black and the scare together so they can fade as one
	var holder := Node2D.new()
	add_child(holder)

	var black := ColorRect.new()
	black.color = Color.BLACK
	black.size = get_viewport().get_visible_rect().size
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(black)   # added first, so it draws behind the fish

	var scare: Node = SCENES.pick_random().instantiate()
	holder.add_child(scare)
	var anim: AnimationPlayer = scare.get_node("AnimationPlayer")
	anim.play("scare")

	# wait until the last FADE_OUT_TIME seconds of the animation
	var wait := maxf(anim.current_animation_length - FADE_OUT_TIME, 0.0)
	await get_tree().create_timer(wait).timeout

	var tween := create_tween()
	tween.tween_property(holder, "modulate:a", 0.0, FADE_OUT_TIME)
	await tween.finished

	holder.queue_free()
	playing = false
