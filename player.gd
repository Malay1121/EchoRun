extends CharacterBody2D
signal player_died
@onready var animated_sprite = $AnimatedSprite2D
@onready var swap_cooldown_timer = $SwapCooldownTimer

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var death_y_position = 1000
var just_swapped = false
var can_jump = true
var can_swap = true

# Get the gravity value from the project's settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if global_position.y > death_y_position:
		player_died.emit()
		return

	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and can_jump:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("swap") and swap_cooldown_timer.is_stopped() and can_swap:
		perform_swap()

	# Get input for left/right movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Update animations
	if is_on_floor():
		if velocity.x != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

	var current_state = {
		"position": self.global_position,
		"animation": animated_sprite.animation,
		"flip_h": animated_sprite.flip_h
	}
	ActionRecorder.record_state(current_state)
	
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider != self and not just_swapped:
			player_died.emit()
			return
	
	just_swapped = false
			
func perform_swap():
	var world = get_parent()
	if world.has_method("get_echo_node") and world.get_echo_node() != null:
		var echo = world.get_echo_node()
		
		var player_pos = self.global_position
		var echo_pos = echo.global_position

		self.global_position = echo_pos
		echo.global_position = player_pos
		
		just_swapped = true
		world.deduct_swap_penalty()

		swap_cooldown_timer.start()


func disable_ability(ability_name, duration):
	if ability_name == "jump":
		can_jump = false
	elif ability_name == "swap":
		can_swap = false

	var enable_timer = get_tree().create_timer(duration, false)
	enable_timer.timeout.connect(func(): enable_ability(ability_name))

func enable_ability(ability_name):
	if ability_name == "jump":
		can_jump = true
	elif ability_name == "swap":
		can_swap = true
