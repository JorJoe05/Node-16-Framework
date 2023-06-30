@tool
extends EditorPlugin

var dock

func _enter_tree():
	# Initialization of the plugin goes here.
	dock = preload("res://addons/BitmapTileCollision/Editor/Dock/dock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Bitmap Tiles")


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_control_from_bottom_panel(dock)
	dock.free()
