@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tab_bar_tab_changed(tab):
	$%Info.visible = tab == 0
	$%Docs.visible = tab == 1
	$%Settings.visible = tab == 2
