## Settings menu - Resolution and display options
extends CanvasLayer

@onready var control = $Control
@onready var resolution_option = $Control/Panel/VBoxContainer/ResolutionOption
@onready var fullscreen_check = $Control/Panel/VBoxContainer/FullscreenCheck
@onready var back_button = $Control/Panel/VBoxContainer/BackButton

# Available resolutions (all 16:9 ratio, base is 320x180)
var resolutions = {
	"320x180 (1x)": Vector2i(320, 180),
	"640x360 (2x)": Vector2i(640, 360),
	"960x540 (3x)": Vector2i(960, 540),
	"1280x720 (4x)": Vector2i(1280, 720),
	"1920x1080 (6x)": Vector2i(1920, 1080),
	"2560x1440 (8x)": Vector2i(2560, 1440)
}

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Setup resolution dropdown
	if resolution_option:
		for res_name in resolutions.keys():
			resolution_option.add_item(res_name)
		resolution_option.item_selected.connect(_on_resolution_selected)

	# Setup fullscreen checkbox
	if fullscreen_check:
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
		fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	# Setup back button
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	# Set current resolution
	_update_current_resolution()

func show_settings() -> void:
	visible = true
	_update_current_resolution()

func hide_settings() -> void:
	visible = false

func _update_current_resolution() -> void:
	"""Update dropdown to show current resolution"""
	if not resolution_option:
		return

	var current_size = DisplayServer.window_get_size()
	var index = 0

	for i in range(resolution_option.item_count):
		var res_name = resolution_option.get_item_text(i)
		var res_size = resolutions[res_name]

		if res_size == current_size:
			resolution_option.selected = i
			return

func _on_resolution_selected(index: int) -> void:
	"""Change window resolution"""
	var res_name = resolution_option.get_item_text(index)
	var new_size = resolutions[res_name]

	print("Changing resolution to: %s (%v)" % [res_name, new_size])

	# Set window size
	DisplayServer.window_set_size(new_size)

	# Center window
	var screen_size = DisplayServer.screen_get_size()
	var window_pos = (screen_size - new_size) / 2
	DisplayServer.window_set_position(window_pos)

	# The viewport is already set to 320x180 in project settings
	# The window will scale it automatically with the stretch mode

func _on_fullscreen_toggled(pressed: bool) -> void:
	"""Toggle fullscreen mode"""
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("Fullscreen enabled")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("Windowed mode")

func _on_back_pressed() -> void:
	"""Return to pause menu"""
	hide_settings()

	# Show pause menu again
	var pause_menu = get_node_or_null("../PauseMenu")
	if pause_menu:
		pause_menu.get_node("Control").visible = true
