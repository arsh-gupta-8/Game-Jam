extends Node2D

var knockTimer = Timer.new()
var DoorKnockSound = AudioStreamPlayer2D.new()
var checkTimer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(knockTimer)
	add_child(checkTimer)
	add_child(DoorKnockSound)
	
	knockTimer.wait_time = 25
	knockTimer.timeout.connect(doorKnock)
	knockTimer.autostart = true
	knockTimer.start()
	
	checkTimer.autostart = false
	checkTimer.wait_time = 5.0
	checkTimer.timeout.connect(jumpScare)
	
	$DoorsceneDoor.material.set_shader_parameter("is_active", false)
	DoorKnockSound.stream = load("res://Assets/Audio/DoorKnock.mp3")
	
	
func doorKnock():
	print("Knocked on the door")
	$DoorsceneDoor.material.set_shader_parameter("is_active", true)
	knockTimer.wait_time = 10
	knockTimer.wait_time = randf_range(15, 25) + Global.depth/60
	DoorKnockSound.play()
	knockTimer.start()
	
	checkTimer.wait_time = 5
	checkTimer.paused = false
	checkTimer.one_shot = false
	checkTimer.start()
		
func jumpScare():
	Jumpscares.play()
	checkTimer.stop() 
	$DoorsceneDoor.material.set_shader_parameter("is_active", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not checkTimer.is_stopped() and not checkTimer.paused:
		if Input.is_action_just_pressed("ui_accept") and (Global.current % 4) == 3:
			checkTimer.paused = true
			$DoorsceneDoor.material.set_shader_parameter("is_active", false)
