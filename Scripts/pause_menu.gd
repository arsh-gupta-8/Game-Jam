extends CanvasLayer

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	resume_button.pressed.connect(resume)
	menu_button.pressed.connect(to_menu)
	quit_button.pressed.connect(get_tree().quit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var game = get_parent()
		if game.in_menu or game.game_over:
			return
		if get_tree().paused:
			resume()
		else:
			pause()


func pause() -> void:
	visible = true
	get_tree().paused = true


func resume() -> void:
	visible = false
	get_tree().paused = false


func to_menu() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
