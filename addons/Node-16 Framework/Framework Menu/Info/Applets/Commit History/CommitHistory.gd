@tool
extends Control

@onready var commit_template = $CommitTemplate

func _refresh():
	if Engine.is_editor_hint():
		var httpreq = HTTPRequest.new()
		add_child(httpreq)
		httpreq.request_completed.connect(_request_completed)
		#var err = httpreq.request("https://api.github.com/repos/SuperFreaksDev/Super-Freaks-1-Ultimate-Edition/commits")
		var err = httpreq.request("https://api.github.com/repos/JorJoe05/Node-16-Framework/commits")
		if err != OK:
			push_error("Error in HTTP request")
	else:
		$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = false

func _request_completed(result, response_code, headers, body):
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Info.tooltip_text = "Last updated at " + Time.get_time_string_from_system()
	for f in $Panel/MarginContainer/VBoxContainer/ScrollContainer/CommitList.get_children():
		f.queue_free()
	var json = JSON.parse_string(body.get_string_from_utf8())
	for f in range(0, json.size()):
		var commit_entry = commit_template.duplicate()
		commit_entry.get_node("VBoxContainer/Author/Author").text = json[f]["author"]["login"]
		if json[f]["author"]["login"] == json[f]["committer"]["login"]:
			commit_entry.get_node("VBoxContainer/Committer").hide()
		else:
			commit_entry.get_node("VBoxContainer/Committer/Committer").text = json[f]["committer"]["login"]
		var commit_message_parts = json[f]["commit"]["message"].split("\n\n", true, 1)
		commit_entry.get_node("VBoxContainer/Title").text = commit_message_parts[0]
		if commit_message_parts.size() > 1:
			commit_entry.get_node("VBoxContainer/Description/Description").text = commit_message_parts[1]
		else:
			commit_entry.get_node("VBoxContainer/Description/Description").hide()
		commit_entry.show()
		$Panel/MarginContainer/VBoxContainer/ScrollContainer/CommitList.add_child(commit_entry)
		_start_reload_cooldown()

func _start_reload_cooldown():
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.hide()
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = true
	await get_tree().create_timer(1200).timeout
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = false
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.show()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	_refresh()


func _on_button_pressed():
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.hide()
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = true
	_refresh()
