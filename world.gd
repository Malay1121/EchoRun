extends Node2D

@export var echo_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 3.0
	spawn_timer.one_shot = true
	
	spawn_timer.timeout.connect(spawn_echo)
	add_child(spawn_timer)
	spawn_timer.start()

func spawn_echo():
	print("Spawning Echo!!!")
	var new_echo = echo_scene.instantiate()
	add_child(new_echo)
