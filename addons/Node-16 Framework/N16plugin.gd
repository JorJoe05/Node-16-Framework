@tool
extends EditorPlugin

const FrameworkMenu = preload("res://addons/Node-16 Framework/Framework Menu/FrameworkMenu.tscn")

var framework_menu_instance

func _enter_tree():
	framework_menu_instance = FrameworkMenu.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(framework_menu_instance)
	_make_visible(false)

func _exit_tree():
	if framework_menu_instance:
		framework_menu_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if framework_menu_instance:
		framework_menu_instance.visible = visible


func _get_plugin_name():
	return "Framework"


func _get_plugin_icon():
	return load("res://addons/Node-16 Framework/icon_sonic.svg")
