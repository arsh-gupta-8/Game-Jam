extends Node2D

@onready var menu: Node2D = $Menu
@onready var menu_ui: CanvasLayer = $Menu/MenuUI
@onready var win_scene: Node2D = $WinScene
@onready var lose_scene: Node2D = $LoseScene

@onready var catch_screen: Node2D = $catch_screen
@onready var dispenser_scene: Node2D = $DispenserScene
@onready var bioreactor_scene: Node2D = $BioreactorScene
@onready var other_scene: Node2D = $OtherScene

#@onready var menu_ui: CanvasLayer = find_canvas_layer(menu)

@onready var views: Array[Node2D] = [
	catch_screen,
	dispenser_scene,
	bioreactor_scene,
	other_scene,
]

var in_menu := true
var game_over := false
var skip_frame := false


func _ready() -> void:
	for view in views:
		view.visible = false
		view.process_mode = Node.PROCESS_MODE_DISABLED
	for end_scene in [win_scene, lose_scene]:
		end_scene.visible = false
		end_scene.process_mode = Node.PROCESS_MODE_DISABLED
	menu.visible = true
	Global.draining = false
	Ambience.stop()
	Global.scene_locked = false
	menu_ui.visible = true



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_J:
		Jumpscares.play()
	if not in_menu:
		return
	var pressed_key = event is InputEventKey and event.pressed and not event.echo
	var pressed_click = event is InputEventMouseButton and event.pressed
	if pressed_key or pressed_click:
		start_game()


func start_game() -> void:
	Global.play_time = 0.0
	Global.heldFish = false
	Global.heldFuel = 0
	Global.fuel = 500
	Global.draining = true
	Global.fishCaught.clear()
	Global.scene_locked = false
	in_menu = false
	skip_frame = true
	menu.visible = false
	menu_ui.visible = false
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	for view in views:
		view.process_mode = Node.PROCESS_MODE_INHERIT
		
	show_view(0)

func _process(delta: float) -> void:
	if game_over:
		return
	if in_menu:
		return

	# Hold off on win/lose and view switching while a fish is dropping or a jumpscare is playing
	if Global.scene_locked or Jumpscares.playing:
		return

	if Global.fuel >= 1000:
		win()
		return
	elif Global.fuel <= 0:
		lose()
		return

	if skip_frame:
		skip_frame = false
		return
	if Input.is_action_just_pressed("switch_right"):
		show_view((Global.current + 1) % views.size())
	elif Input.is_action_just_pressed("switch_left"):
		show_view((Global.current - 1 + views.size()) % views.size())

func show_view(index: int) -> void:
	print_stack()
	print("show_view: ", index)
	Global.current = index
	Ambience.start()   
	for i in views.size():
		var active = i == Global.current
		views[i].visible = active
		

func show_ending(target: Node2D) -> void:
	game_over = true
	Global.draining = false
	Ambience.stop()
	for view in views:
		view.visible = false
		view.process_mode = Node.PROCESS_MODE_DISABLED
	target.visible = true
	target.process_mode = Node.PROCESS_MODE_INHERIT

func win() -> void:
	show_ending(win_scene)

func lose() -> void:
	show_ending(lose_scene)
