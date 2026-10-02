extends Node2D

@onready var catch_screen: Node2D = $catch_screen
@onready var dispenser_scene: Node2D = $DispenserScene

func _ready() -> void:
	show_scene(catch_screen)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_left"):
		show_scene(catch_screen)
	elif Input.is_action_just_pressed("switch_right"):
		show_scene(dispenser_scene)

func show_scene(target: Node2D) -> void:
	for scene in [catch_screen, dispenser_scene]:
		var active = scene == target
		scene.visible = active
		scene.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
