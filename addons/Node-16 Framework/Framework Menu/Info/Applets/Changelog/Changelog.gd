@tool
extends Control

@onready var changelog = "res://CHANGELOG.md"

func _refresh():
	var file = FileAccess.open(changelog, FileAccess.READ)
	$Panel/MarginContainer/VBoxContainer/Changelog.text = file.get_as_text()
	file.close()

# Called when the node enters the scene tree for the first time.
func _ready():
	_refresh()

func _on_refresh_pressed():
	_refresh()
