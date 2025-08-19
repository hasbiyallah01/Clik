extends Node2D

# --- Game State ---
var score: int = 0
var square_size: int = 64
var time_left: float = 30.0
var game_active: bool = true

# --- Nodes ---
@onready var square: ColorRect = $Square
@onready var score_label: Label = $ScoreLabel
@onready var timer_label: Label = $TimerLabel
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var restart_button: Button = $RestartButton
@onready var background: TextureRect = $Background

func _ready():
	# Init background
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.size = get_viewport_rect().size
	background.position = Vector2.ZERO

	# Init square
	square.size = Vector2(square_size, square_size)
	square.color = Color.RED
	square.gui_input.connect(Callable(self, "_on_square_clicked"))

	# Init labels
	score_label.text = "Score: 0"
	score_label.position = Vector2(10, 10)

	timer_label.text = "Time: %d" % int(time_left)
	timer_label.position = Vector2(10, 40)

	# Init restart button
	restart_button.text = "Restart"
	restart_button.position = Vector2(10, 70)
	restart_button.hide()
	restart_button.pressed.connect(_on_restart_pressed)

	# Start game
	move_square()
	set_process(true)

func _process(delta):
	if not game_active:
		return

	# Countdown
	time_left -= delta
	timer_label.text = "Time: %d" % int(time_left)

	# End game
	if time_left <= 0:
		end_game()

func move_square():
	var screen_size = get_viewport_rect().size

	# 🎲 Random size between 40 and 100
	var new_size = randf_range(40.0, 100.0)
	square.size = Vector2(new_size, new_size)

	# Update limits based on new size
	var max_x = screen_size.x - new_size
	var max_y = screen_size.y - new_size

	# Make sure square doesn’t overlap labels
	var min_x = score_label.position.x + score_label.get_minimum_size().x + 10
	var min_y = timer_label.position.y + timer_label.get_minimum_size().y + 10

	# Move to a new random position
	square.position = Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y)
	)

	# 🎨 Change square color each move
	square.color = Color(randf(), randf(), randf())


func _on_square_clicked(event):
	if not game_active:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		score += 1
		score_label.text = "Score: %d" % score

		# Move and play effects
		move_square()
		if click_sound:
			click_sound.play()

		# Animate "pop" effect
		var original_scale = square.scale
		square.scale = original_scale * 1.2
		await get_tree().create_timer(0.08).timeout
		square.scale = original_scale

func _input(event):
	if not game_active:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Penalize if clicked outside square
		if not square.get_global_rect().has_point(event.position):
			score -= 1
			score_label.text = "Score: %d" % score

func end_game():
	game_active = false
	timer_label.text = "Time: 0"
	score_label.text += "   GAME OVER!"
	square.hide()
	restart_button.show()

func _on_restart_pressed():
	# Reset state
	score = 0
	time_left = 30.0
	game_active = true

	score_label.text = "Score: 0"
	timer_label.text = "Time: %d" % int(time_left)

	# Show square again
	square.show()
	move_square()
	restart_button.hide()
