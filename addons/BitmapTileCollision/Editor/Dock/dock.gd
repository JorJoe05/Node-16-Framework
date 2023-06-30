@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tab_bar_tab_changed(tab):
	$VBoxContainer/CreateMenu.visible = tab == 0
	$VBoxContainer/PaintMenu.visible = tab == 1
	
