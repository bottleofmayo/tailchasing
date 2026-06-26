extends Path3D

@export var move_speed: float = 0.1
@export var radius = 10.0
var spins = 0
var progress = 0 
var speed_up = false
signal spins_changed(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_circle_path()

func create_circle_path():
	if radius <= 0.6:
		return
	var new_curve = Curve3D.new()
	var segments = 360

	for i in range(segments + 1):
		var angle = float(i) / segments * PI * 2.0
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		new_curve.add_point(Vector3(x, 0, z))

	self.curve = new_curve

func _process(delta: float) -> void:
	progress += move_speed * delta * 60
	$PathFollow3D.progress = progress
	if int(floor(progress / (radius * 2 * PI))) != spins:
		update_spins(1)
	if not speed_up and Input.is_action_just_pressed("click"):
		speed_up = true
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.start()
		timer.timeout.connect(_on_timer_timeout)
		move_speed += 0.1
	if spins >= 10000:
		%Shader.hide()
		%CanvasLayer.hide()
		%Shader2.show()
		%BlackHole.start_black_hole()
		

func _on_timer_timeout():
	move_speed -= 0.1
	speed_up = false

func update_spins(score):
	spins += score
	#var tween = create_tween()
	#%SpinsLabel.scale = Vector2(1.2, 1.2)
	#tween.tween_property(%SpinsLabel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	%SpinsLabel.text = "Spins: " + str(spins)
	spins_changed.emit(spins)
	
