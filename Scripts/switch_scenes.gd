extends Node2D

@onready var menu: Node2D = $Menu
@onready var menu_ui: CanvasLayer = $Menu/MenuUI

@onready var catch_screen: Node2D = $catch_screen
@onready var dispenser_scene: Node2D = $DispenserScene
@onready var bioreactor_scene: Node2D = $BioreactorScene
@onready var other_scene: Node2D = $OtherScene

# lose screens (just a sprite each)
@onready var depth_lose_scene: Node2D = $DepthLoseScene
@onready var oxygen_lose_scene: Node2D = $OxygenLoseScene

# videos
@onready var video_layer: CanvasLayer = $VideoLayer
@onready var video_player: VideoStreamPlayer = $VideoLayer/VideoPlayer

const INTRO_VIDEO := "res://Assets/Videos/Starting_animation.ogv"
const OXYGEN_LOSE_VIDEO := "res://Assets/Videos/Blinking_oxygen_ending.ogv"
const DEPTH_LOSE_VIDEO := "res://Assets/Videos/Depth_ending.ogv"
const WIN_VIDEO := "res://Assets/Videos/Good_ending.ogv"
const LOSE_SCREEN_TIME := 6.0

# static = survives reload_current_scene(), so the intro only plays on first launch
static var intro_played := false

@onready var views: Array[Node2D] = [
	catch_screen,
	dispenser_scene,
	bioreactor_scene,
	other_scene,
]

var in_menu := false        # true only while the menu is waiting for a click
var game_running := false   # true only while actually playing
var game_over := false
var skip_frame := false


func _ready() -> void:
	for view in views:
		view.visible = false
		view.process_mode = Node.PROCESS_MODE_DISABLED
	for end_scene in [depth_lose_scene, oxygen_lose_scene]:
		end_scene.visible = false
		end_scene.process_mode = Node.PROCESS_MODE_DISABLED
	video_layer.visible = false
	Global.draining = false
	Global.scene_locked = false
	Ambience.stop()

	# keep the menu hidden until the intro is done (first launch only)
	menu.visible = false
	menu_ui.visible = false
	if not intro_played:
		intro_played = true
		await play_video(INTRO_VIDEO)

	menu.visible = true
	menu_ui.visible = true
	in_menu = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_J:
		Jumpscares.play()   # debug key, delete this when you're done testing
	if not in_menu:
		return
	var pressed_key = event is InputEventKey and event.pressed and not event.echo
	var pressed_click = event is InputEventMouseButton and event.pressed
	if pressed_key or pressed_click:
		start_game()


func start_game() -> void:
	in_menu = false
	menu.visible = false
	menu_ui.visible = false
	menu.process_mode = Node.PROCESS_MODE_DISABLED

	Global.play_time = 0.0
	Global.heldFish = false
	Global.heldFuel = 0
	Global.fuel = 500
	Global.depth = Global.depthStart
	Global.fishCaught.clear()
	Global.draining = true
	Global.scene_locked = false
	skip_frame = true

	for view in views:
		view.process_mode = Node.PROCESS_MODE_INHERIT

	game_running = true
	show_view(0)


func _process(delta: float) -> void:
	if game_over or not game_running:
		return

	# hold off while a fish is dropping or a jumpscare is playing
	if Global.scene_locked or Jumpscares.playing:
		return

	if Global.fuel >= 1000:
		win()
		return
	elif Global.depth <= 0:
		lose_depth()
		return
	elif Global.fuel <= 0:
		lose_oxygen()
		return

	if skip_frame:
		skip_frame = false
		return
	if Input.is_action_just_pressed("switch_right"):
		show_view((Global.current + 1) % views.size())
	elif Input.is_action_just_pressed("switch_left"):
		show_view((Global.current - 1 + views.size()) % views.size())


func show_view(index: int) -> void:
	Global.current = index
	Ambience.start()
	for i in views.size():
		views[i].visible = (i == Global.current)


func show_ending(target: Node2D) -> void:
	game_over = true
	game_running = false
	Global.draining = false
	Ambience.stop()
	for view in views:
		view.visible = false
		view.process_mode = Node.PROCESS_MODE_DISABLED
	if target:
		target.visible = true
		target.process_mode = Node.PROCESS_MODE_INHERIT
		var sound = target.get_node_or_null("DeathSound")
		if sound:
			sound.play()
		else:
			push_warning("No node named DeathSound in " + target.name)

func play_video(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Video not found: " + path)
		return   # skip instead of hanging forever
	video_player.stream = load(path)
	video_layer.visible = true
	video_player.play()
	await video_player.finished
	video_layer.visible = false


func end_game(screen: Node2D, video: String) -> void:
	show_ending(screen)
	if screen:
		await get_tree().create_timer(LOSE_SCREEN_TIME).timeout
		var sound = screen.get_node_or_null("DeathSound")
		if sound:
			sound.stop()
	await play_video(video)
	get_tree().reload_current_scene()

func win() -> void:
	end_game(null, WIN_VIDEO)


func lose_oxygen() -> void:
	end_game(oxygen_lose_scene, OXYGEN_LOSE_VIDEO)


func lose_depth() -> void:
	end_game(depth_lose_scene, DEPTH_LOSE_VIDEO)
