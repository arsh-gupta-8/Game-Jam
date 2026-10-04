extends CanvasLayer

@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	quit_button.pressed.connect(get_tree().quit)
	
