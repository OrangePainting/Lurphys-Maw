extends Node
# autoload

const Bubbles = preload("uid://es4fchmn1rku")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# spawn bubbles at position where player dashed
func spawn_bubbles(position: Vector2) -> void:
	var b = Bubbles.instantiate()
	add_child(b)
	b.position = position
