extends Node2D

signal generation_finished

@export var num_walkers: int = 3
@export var max_iterations: int = 1000
@export var custom_viewport_size := Vector2(1280, 720)
@export var step_size: int = 64
@export_range(0.0, 1.0) var ground_chance: float = 1.0
@export var tile_size: int = 64

@export var ground_tile_coords: Vector2i = Vector2i.ZERO
@export var wall_tile_coords: Vector2i = Vector2i.ZERO
@export var borders: int = 0
@export var steps_per_frame: int = 18

@onready var ground_layer: TileMapLayer = %Ground
@onready var wall_layer: TileMapLayer = %Wall
#@onready var camera: Camera2D = %Camera2D

var walkers: Array[Vector2i] = []
var iterations_count: int = 0
var is_simulation_running: bool = false
var viewport_size: Vector2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("Resetting simulation")
		reset_simulation()

func reset_simulation():
	ground_layer.clear()
	wall_layer.clear()
	walkers.clear()
	
	var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	var center: Vector2i = grid_size / 2
	print(grid_size, center)
	for i in range(num_walkers):
		walkers.append(center)
		ground_layer.set_cell(Vector2i(center.x, center.y), 2, ground_tile_coords)
	
	iterations_count = 0
	is_simulation_running = true

func create_level():
	if not is_simulation_running: return
	for i in range(steps_per_frame): # perform multiple steps per generation
		if iterations_count >= max_iterations: break
		update_walkers()
		iterations_count += 1
	
	if iterations_count >= max_iterations:
		fill_wall()
		is_simulation_running = false
		generation_finished.emit()

func get_spawn_position() -> Vector2:
	var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	var center: Vector2i = grid_size / 2
	return Vector2(center * tile_size) + Vector2(tile_size, tile_size) / 2.0

func update_walkers():
	var tiles_placed: int = 0
	var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	var min_bound: Vector2i = Vector2i.ONE * borders
	var max_bound: Vector2i = grid_size - Vector2i.ONE * borders
	
	for i in range(len(walkers)):
		var direction: Vector2i = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT][randi() % 4]
		var new_pos: Vector2i = walkers[i] + direction
		if (new_pos.x >= min_bound.x and new_pos.x < max_bound.x and
			new_pos.y >= min_bound.y and new_pos.y < max_bound.y):
				walkers[i] = new_pos #update walker.position
				ground_layer.set_cell(new_pos, 0, ground_tile_coords)
				tiles_placed += 1

 
func fill_wall() -> void:
	var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	var placed_tiles: int = 0
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell_pos: Vector2i = Vector2i(x, y)
			if ground_layer.get_cell_source_id(cell_pos) == -1: # if cell empty
				wall_layer.set_cell(cell_pos, 4, wall_tile_coords)
				placed_tiles += 1
	print("backgorund tiles placed :", placed_tiles)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = custom_viewport_size
	#if camera:
		#var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
		#camera.position = Vector2(grid_size * tile_size) / 2
		#camera.zoom = Vector2(0.7, 0.7)
	
	# start simulation
	reset_simulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	create_level()
