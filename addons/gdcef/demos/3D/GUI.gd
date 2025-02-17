# ==============================================================================
# Demo based on the initial asset https://godotengine.org/asset-library/asset/127
# Basic application showing how to use CEF inside Godot with a 3D scene and mouse
# and keyboard events.
# ==============================================================================

extends Control

# Name of the browser
const browser1 = "browser1"

# Memorize if the mouse was pressed
var mouse_pressed : bool = false

# ==============================================================================
# Home button pressed: get the browser node and load a new page.
# ==============================================================================
func _on_Home_pressed():
	var browser = $CEF.get_node(browser1)
	if browser == null:
		$Panel/Label.set_text("Failed getting Godot node " + browser1)
		return
	browser.load_url("https://bitbucket.org/chromiumembedded/cef/wiki/Home")
	pass

# ==============================================================================
# Go to previously visited page
# ==============================================================================
func _on_Prev_pressed():
	var browser = $CEF.get_node(browser1)
	if browser == null:
		$Panel/Label.set_text("Failed getting Godot node " + browser1)
		return
	browser.previous_page()
	pass

# ==============================================================================
# Go to next page
# ==============================================================================
func _on_Next_pressed():
	var browser = $CEF.get_node(browser1)
	if browser == null:
		$Panel/Label.set_text("Failed getting Godot node " + browser1)
		return
	browser.next_page()
	pass

# ==============================================================================
# Callback when a page has ended to load: we print a message
# ==============================================================================
func _on_page_loaded(node):
	$Panel/Label.set_text(node.name + ": page " + node.get_url() + " loaded")

# ==============================================================================
# On new URL entered
# ==============================================================================
func _on_TextEdit_text_changed(new_text):
	var browser = $CEF.get_node(browser1)
	if browser == null:
		$Panel/Label.set_text("Failed getting Godot node " + browser1)
		return
	browser.load_url(new_text)

# ==============================================================================
# Get mouse events and broadcast them to CEF
# ==============================================================================
func _on_TextureRect_gui_input(event):
	var browser = $CEF.get_node(browser1)
	if browser == null:
		$Panel/Label.set_text("Failed getting Godot node " + browser1)
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			browser.on_mouse_wheel_vertical(2)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			browser.on_mouse_wheel_vertical(-2)
		elif event.button_index == BUTTON_LEFT:
			mouse_pressed = event.pressed
			if event.pressed == true:
				browser.on_mouse_left_down()
			else:
				browser.on_mouse_left_up()
		elif event.button_index == BUTTON_RIGHT:
			mouse_pressed = event.pressed
			if event.pressed == true:
				browser.on_mouse_right_down()
			else:
				browser.on_mouse_right_up()
		else:
			mouse_pressed = event.pressed
			if event.pressed == true:
				browser.on_mouse_middle_down()
			else:
				browser.on_mouse_middle_up()
	elif event is InputEventMouseMotion:
		if mouse_pressed == true :
			browser.on_mouse_left_down()
		browser.on_mouse_moved(event.position.x, event.position.y)
	pass

# ==============================================================================
# Make the CEF browser reacts from keyboard events.
# ==============================================================================
func _input(event):
	var browser = $CEF.get_node(browser1)
	if browser == null:
		$Panel/Label.set_text("Failed getting Godot node " + browser1)
		return
	if event is InputEventKey:
		if event.unicode != 0:
			browser.on_key_pressed(event.unicode, event.pressed, event.shift, event.alt, event.control)
		else:
			browser.on_key_pressed(event.scancode, event.pressed, event.shift, event.alt, event.control)
	pass

# ==============================================================================
# Create a single briwser named "browser1" that is attached as child node to $CEF.
# ==============================================================================
func _ready():

	# Configuration are:
	#   resource_path := {"artifacts", CEF_ARTIFACTS_FOLDER}
	#   resource_path := {"exported_artifacts", application_real_path()}
	#   {"incognito":false}
	#   {"cache_path", resource_path / "cache"}
	#   {"root_cache_path", resource_path / "cache"}
	#   {"browser_subprocess_path", resource_path / SUBPROCESS_NAME }
	#   {"log_file", resource_path / "debug.log"}
	#   {log_severity", "warning"}
	#   {"remote_debugging_port", 7777}
	#   {"exception_stack_size", 5}
	#
	# Configurate CEF. In incognito mode cache directories not used and in-memory
	# caches are used instead and no data is persisted to disk.
	#
	# artifacts: allows path such as "build" or "res://build/". Note that "res://"
	# will use ProjectSettings.globalize_path but exported projects don't support globalize_path:
	# https://docs.godotengine.org/en/3.5/classes/class_projectsettings.html#class-projectsettings-method-globalize-path
	var resource_path = "res://build/"
	if !$CEF.initialize({"artifacts":resource_path, "incognito":true, "locale":"en-US"}):
		push_error($CEF.get_error())
		get_tree().quit()
		return

	var S = $Panel/TextureRect.get_size()
	var browser = $CEF.create_browser("https://github.com/Lecrapouille/gdcef", browser1, S.x, S.y, {"javascript":true})
	browser.connect("page_loaded", self, "_on_page_loaded")
	$Panel/TextureRect.texture = browser.get_texture()

# ==============================================================================
# $CEF is periodically updated
# ==============================================================================
func _process(_delta):
	pass
