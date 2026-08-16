extends Node2D

@onready var proc_gen := %ProcGen
@onready var player := %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.hide()
	player.set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_generation_finished() -> void:
	player.position = proc_gen.get_spawn_position()
	player.show()
	player.set_physics_process(true)
