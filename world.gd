extends Node2D

@export var chunks: Array[PackedScene]
@export var echo_scene: PackedScene
@onready var hud = $HUD
@onready var player = $Player

var score = 0
var max_score = 0
var spawn_distance = 1000
var despawn_distance = 1000
var next_spawn_position = Vector2.ZERO
var echo_node = null
@onready var game_over_ui = $GameOverUI

var max_x_achieved = 0
var is_game_over = false

func _ready():
	player.player_died.connect(game_over)
	game_over_ui.restart_requested.connect(restart_game)
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(spawn_echo)
	add_child(spawn_timer)
	spawn_timer.start()
	
	for i in 3:
		spawn_chunk()

func get_echo_node():
	return echo_node

func _process(delta):
	if is_game_over:
		return 

	if player.global_position.x > max_x_achieved:
		max_x_achieved = player.global_position.x
	var current_score = int(max_x_achieved)
	hud.update_score(current_score)

	if player.global_position.x > next_spawn_position.x - spawn_distance:
		spawn_chunk()
	despawn_chunks()

func game_over():
	is_game_over = true
	get_tree().paused = true
	game_over_ui.show_with_score(int(max_x_achieved))

func restart_game():
	get_tree().paused = false
	ActionRecorder.reset()
	get_tree().reload_current_scene()

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
	
	if echo_node != null and echo_node.global_position.x < rearmost_x:
		rearmost_x = echo_node.global_position.x
		
	var despawn_x_limit = rearmost_x - despawn_distance
	
	for chunk in get_children():
		if not chunk is Node2D or not chunk.has_node("EndMarker"):
			continue
			
		if chunk.global_position.x < despawn_x_limit:
			chunk.queue_free()
func deduct_swap_penalty():
	max_x_achieved *= 0.75
