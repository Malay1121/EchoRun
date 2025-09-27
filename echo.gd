extends CharacterBody2D

@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@export var delay_msec = 5000

func _physics_process(delta: float) -> void:
	var target_timestamp = Time.get_ticks_msec() - delay_msec
	
	if target_timestamp < 0:
		self.visible = false
		collision_shape.disabled = true
		return
	
	self.visible = true
	collision_shape.disabled = false
	var target_state = find_state_for_timestamp(target_timestamp)

	if target_state:
		self.global_position = self.global_position.lerp(target_state["position"], 0.5)
		animated_sprite.play(target_state["animation"])
		animated_sprite.flip_h = target_state["flip_h"]

func find_state_for_timestamp(timestamp: int) -> Dictionary:
	var history = ActionRecorder.history
	if history.is_empty():
		return {}

	for i in range(history.size() - 1, -1, -1):
		if history[i]["timestamp"] <= timestamp:
			return history[i]
	
	return {}
