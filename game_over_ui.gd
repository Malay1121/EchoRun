extends CanvasLayer

signal restart_requested

@onready var score_label = $Panel/ScoreLabel
@onready var restart_button = $Panel/Button

func _ready():
	restart_button.pressed.connect(_on_restart_button_pressed)
	hide()

func show_with_score(final_score):
	score_label.text = "Score: " + str(final_score / 10)
	show()

func _on_restart_button_pressed():
	hide()
	restart_requested.emit()
