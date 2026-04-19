extends Node2D

var started = false

func _ready() -> void:
	$SignedInAs.visible = false
	
func _process(_delta: float) -> void:
	if not started and Session.loaded:
		start()

func start():
	started = true
	
	if not Session.user:
		get_tree().change_scene_to_file.call_deferred("res://auth/login.tscn")
	else:
		$SignedInAs/EmailLabel.text = Session.user.email
		$SignedInAs.visible = true
