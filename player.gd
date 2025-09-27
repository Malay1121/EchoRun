extends CharacterBody2D
signal player_died
@onready var animated_sprite = $AnimatedSprite2D
const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var death_y_position = 1000
# Get the gravity value from the project's settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if (global_position.y > death_y_position):
		ActionRecorder.reset()
		player_died.emit()
		return
	
	# Add gravity ONLY if the player is in the air.
	if not is_on_floor():
		velocity.y += gravity * delta  # Correctly applies gravity to the y-axis

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction for left/right movement.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if velocity.x != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	
	var current_state = {"position": self.global_position, "animation": animated_sprite.animation, "flip_h": animated_sprite.flip_h}
	ActionRecorder.record_state(current_state)
	# The function that actually moves the character
	move_and_slide()
	
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		if (collision.get_collider().name == "Echo"):
			print("Game Over, player collided! GET BETTER!")
			ActionRecorder.reset()
			player_died.emit()
			return
			
