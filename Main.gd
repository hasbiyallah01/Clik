extends Node2D

var score = 0
var square_size = 64

@onready var square = $Square  # ColorRect node
@onready var score_label = $ScoreLabel  # Label node

func _ready():
	# Set up the square properties
	square.size = Vector2(square_size, square_size)
	square.color = Color.RED
	
	# Set up the score label
	score_label.text = "Score: 0"
	score_label.position = Vector2(10, 10)
	
	# Position the square for the first time
	move_square()
	
	# Connect the square click event
	square.gui_input.connect(_on_square_clicked)

func move_square():
	# Get screen dimensions
	var screen_size = get_viewport_rect().size
	
	# Calculate random position ensuring square stays on screen
	var max_x = screen_size.x - square_size
	var max_y = screen_size.y - square_size
	
	square.position.x = randf() * max_x
	square.position.y = randf() * max_y

func _on_square_clicked(event):
	# Check if it's a mouse button press (left click)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		score += 1
		score_label.text = "Score: " + str(score)
		move_square()
		
		# Optional: Add a small visual feedback
		square.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		square.modulate = Color.RED
