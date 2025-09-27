extends Node2D

@export var chunks: Array[PackedScene]
@export var echo_scene: PackedScene

@onready var player = $Player

var spawn_distance = 1000
var despawn_distance = 1000
var next_spawn_position = Vector2.ZERO
var echo_node = null

func _ready():
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 3.0
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(spawn_echo)
	add_child(spawn_timer)
	spawn_timer.start()
	
	for i in 3:
		spawn_chunk()

func _process(delta):
	if player.global_position.x > next_spawn_position.x - spawn_distance:
		spawn_chunk()
	
	despawn_chunks()

func spawn_chunk():
	if chunks.is_empty():
		return

	var random_chunk_scene = chunks.pick_random()
	var new_chunk = random_chunk_scene.instantiate()
	
	new_chunk.global_position = next_spawn_position
	add_child(new_chunk)
	
	var end_marker = new_chunk.get_node("EndMarker")
	next_spawn_position = end_marker.global_position

func spawn_echo():
	print("Spawning Echo!")
	var new_echo = echo_scene.instantiate()
	add_child(new_echo)
	echo_node = new_echo

func despawn_chunks():
	var rearmost_x = player.global_position.x
	
	# This safer check now uses '!= null'
	if echo_node != null and echo_node.global_position.x < rearmost_x:
		rearmost_x = echo_node.global_position.x
		
	var despawn_x_limit = rearmost_x - despawn_distance
	
	for chunk in get_children():
		if not chunk is Node2D or not chunk.has_node("EndMarker"):
			continue
			
		if chunk.global_position.x < despawn_x_limit:
			chunk.queue_free()
