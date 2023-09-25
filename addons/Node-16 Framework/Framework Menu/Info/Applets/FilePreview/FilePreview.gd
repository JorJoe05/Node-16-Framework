@tool
extends Control

@export_file @onready var file_path

func _refresh():
	var file = FileAccess.open(file_path, FileAccess.READ)
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Label.text = file_path.get_file()
	$Panel/MarginContainer/VBoxContainer/Changelog.text = file.get_as_text()
	file.close()

# Called when the node enters the scene tree for the first time.
func _ready():
	_refresh()

func _on_refresh_pressed():
	_refresh()
