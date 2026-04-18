@tool
extends Node2D
class_name Stack

@export var tex: Texture2D = null:
	set(new_tex):
		tex = new_tex
		_stack_sprites()
		
@export var frames: int = 10:
	set(new_frames):
		frames = new_frames
		_stack_sprites()
	
@export var gap: float = 1.0:
	set(new_gap):
		gap = new_gap
		_stack_sprites()

@export var stack_rotation: float = 0.0:
	set(new_rot):
		stack_rotation = new_rot
		_stack_sprites()

func _ready():
	_stack_sprites()

func _stack_sprites():
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	
	if tex == null:
		push_warning("no texture")
	
	for i in range(frames):
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.hframes = frames
		sprite.frame = i
		sprite.rotation_degrees = stack_rotation
		sprite.position.y = -i * gap
		add_child(sprite)
		
func _physics_process(delta: float) -> void:
	stack_rotation += delta * 10
	
	if get_child_count() > 0:
		for child in get_children():
			child.rotation_degrees = stack_rotation
	
