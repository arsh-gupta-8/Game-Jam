extends Node2D

const SPEED_MIN := 150.0   # slowest fish
const SPEED_MAX := 400.0   # fastest fish
var catchCDLength: int = 1
var catchCD: Timer = Timer.new()

@export var catch_radius: float = 500.0  
var catch_center: Vector2

var fish_types: Dictionary = {}   # type name -> {"bodies": [...], "spots": [...]}

const FISH_FOLDER := "res://Assets/Fish/"
const INFECTED_CHANCE := 0.5      # roughly 50/50
const EASTER_EGG_CHANCE := 0.03   # how often the FIN logo fish shows up

# Remember: LOWER depth = darker = more fish and more fuel.
# "SHALLOW" values are used at START_DEPTH, "DEEP" values at DARK_DEPTH.
const SPAWN_WAIT_SHALLOW := Vector2(2.0, 3.5)   # seconds between fish (min, max)
const SPAWN_WAIT_DEEP := Vector2(0.4, 0.9)

const FUEL_SHALLOW := Vector2i(100, 100)   # fuel range for a good fish (min, max)
const FUEL_DEEP := Vector2i(100, 100)
var spawnTimer = Timer.new()

# get darker as depth is lower
const START_DEPTH := 1000     # depth where it's fully bright
const DARK_DEPTH := 0   # depth where it's at its darkest
const MAX_DARKNESS := 0.85   # 1.0 would be pure black
@onready var dark_tint: ColorRect = $DarkTint

# smokescreen
@onready var smokescreen: Sprite2D = $Smokescreen
@onready var catch_sound: AudioStreamPlayer2D = $CatchSound
const FADE_IN_TIME := 0.1    # fast
const FADE_OUT_TIME := 0.9   # slower
var flash_tween: Tween

func _ready() -> void:
	load_fish_types()
	spawnTimer.autostart = true
	spawnTimer.wait_time = 3.0
	spawnTimer.timeout.connect(spawnNewFish)
	add_child(spawnTimer)

	catchCD.wait_time = catchCDLength
	catchCD.one_shot = true
	add_child(catchCD)

	catch_center = Vector2(1305, 555)
	queue_redraw()
	
	smokescreen.modulate.a = 0.0

# stuff
func depth_factor() -> float:
	# 0.0 = shallow/bright, 1.0 = deepest/darkest
	return clampf(inverse_lerp(START_DEPTH, DARK_DEPTH, Global.depth), 0.0, 1.0)

func load_fish_types() -> void:
	for file_name in ResourceLoader.list_directory(FISH_FOLDER):
		if file_name.ends_with("/") or file_name.ends_with(".import"):
			continue
		var tex = ResourceLoader.load(FISH_FOLDER + file_name)
		if not (tex is Texture2D):
			continue

		# "Fish1_infection3.PNG" -> type "Fish1", variant "infection3"
		var parts := file_name.get_basename().split("_", true, 1)
		var type_name := parts[0]
		var variant := parts[1].to_lower() if parts.size() > 1 else ""

		if not fish_types.has(type_name):
			fish_types[type_name] = {"bodies": [], "spots": []}

		if variant.begins_with("infection"):
			fish_types[type_name]["spots"].append(tex)
		else:
			fish_types[type_name]["bodies"].append(tex)

func pick_fish_type() -> String:
	# Types with infection spots are the normal fish; types without are easter eggs
	var normal: Array = []
	var rare: Array = []
	for type_name in fish_types:
		if fish_types[type_name]["spots"].is_empty():
			rare.append(type_name)
		else:
			normal.append(type_name)
	if not rare.is_empty() and (normal.is_empty() or randf() < EASTER_EGG_CHANCE):
		return rare.pick_random()
	return normal.pick_random()

func roll_fuel() -> int:
	# random but the whole range moves up as depth gets lower
	var t := depth_factor()
	var lo := lerpf(FUEL_SHALLOW.x, FUEL_DEEP.x, t)
	var hi := lerpf(FUEL_SHALLOW.y, FUEL_DEEP.y, t)
	return randi_range(roundi(lo), roundi(hi))

func make_catch_entry(fish: Node) -> Dictionary:
	var infected: bool = fish.get_meta("infected")
	return {
		"type": fish.get_meta("type"),
		"body_texture": fish.get_meta("body_texture"),
		"spot_texture": fish.get_meta("spot_texture"),
		"infected": infected,
		"fuel": 0 if infected else roll_fuel(),
	}


func spawnNewFish():
	print("Spawned a fish!")
	var t := depth_factor()
	spawnTimer.wait_time = randf_range(
		lerpf(SPAWN_WAIT_SHALLOW.x, SPAWN_WAIT_DEEP.x, t),
		lerpf(SPAWN_WAIT_SHALLOW.y, SPAWN_WAIT_DEEP.y, t))

	var type_name := pick_fish_type()
	var type_data: Dictionary = fish_types[type_name]
	var body_tex: Texture2D = type_data["bodies"].pick_random()
	var infected: bool = randf() < INFECTED_CHANCE and not type_data["spots"].is_empty()
	var spot_tex: Texture2D = type_data["spots"].pick_random() if infected else null

	var fish = CharacterBody2D.new()
	fish.z_index = 4
	var fish_script = load("res://Scripts/fishConstraint.gd")
	fish.set_script(fish_script)

	var fishBody = Sprite2D.new()
	fishBody.scale.x = 0.3
	fishBody.scale.y = 0.3
	fishBody.texture = body_tex
	fishBody.modulate = Color(0.537, 0.745, 0.992, 0.902) 
	fish.add_child(fishBody)
	fish.set_meta("type", type_name)
	fish.set_meta("body_texture", body_tex)
	fish.set_meta("spot_texture", spot_tex)
	fish.set_meta("infected", infected)

	add_child(fish)
	var screenSize = get_viewport_rect().size
	var centerPosition = Vector2(randf_range(1304 - 0.15*screenSize.x, 1304 + 0.15*screenSize.x), randf_range(555 - 0.15*screenSize.y, 555 + 0.15*screenSize.y))

	var random_angle = randf_range(0.0, TAU)
	var offset_vector = Vector2.from_angle(random_angle) * catch_radius
	var spawnPos = catch_center + offset_vector

	var directionVector = centerPosition - spawnPos
	if directionVector.angle() > -PI/2 and directionVector.angle() < PI/2:
		fishBody.flip_v = true
	fishBody.rotate(directionVector.angle()+PI)
	if infected:
		var spot := Sprite2D.new()
		spot.texture = spot_tex
		spot.flip_v = fishBody.flip_v   # flipping doesn't carry over to children, so copy it
		fishBody.add_child(spot)
	fish.global_position = spawnPos

	var fish_speed := randf_range(SPEED_MIN, SPEED_MAX)
	var setVelocity = directionVector.normalized() * fish_speed
	fish.velocity = setVelocity


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and catchCD.time_left <= 0 and (Global.current % 4) == 0:
		var caught_any := false
		for child in get_children():
			if child is CharacterBody2D:
				if child.global_position.distance_to(catch_center) <= catch_radius:
					Global.fishCaught.append(make_catch_entry(child))
					child.queue_free()
					caught_any = true
		if caught_any:
			catchCD.start()
			play_catch_effect()
		print(Global.fishCaught)
	
	# get darker as depth is lower
	var t := clampf(inverse_lerp(START_DEPTH, DARK_DEPTH, Global.depth), 0.0, 1.0)
	dark_tint.color.a = t * MAX_DARKNESS
	
func play_catch_effect() -> void:
	catch_sound.play()

	if flash_tween and flash_tween.is_running():
		flash_tween.kill()   # restart cleanly if a catch happens mid-fade

	smokescreen.modulate.a = 0.0
	flash_tween = create_tween()
	flash_tween.tween_property(smokescreen, "modulate:a", 1.0, FADE_IN_TIME)
	flash_tween.tween_property(smokescreen, "modulate:a", 0.0, FADE_OUT_TIME)
