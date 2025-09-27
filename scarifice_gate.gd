extends Area2D

@export var ability_to_disable: String = "jump"
@export var duration: float = 3.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		body.disable_ability(ability_to_disable, duration)
		$CollisionShape2D.disabled = true
