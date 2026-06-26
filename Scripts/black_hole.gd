extends MeshInstance3D

@export var pull_strength: float = 2.0
@export var event_horizon_distance: float = 1.0
@export var inverse_distance: bool = true

var _attracted_nodes: Array[Node3D] = []
var _active: bool = false

func _ready() -> void:
	_gather_nodes(get_tree().current_scene)

func _gather_nodes(root: Node) -> void:
	for child in root.get_children():
		if child is Node3D and child != self:
			_attracted_nodes.append(child)
		if child.get_child_count() > 0:
			_gather_nodes(child)

## Call this to activate the black hole — reveals the shader, then pulls everything in
## starting at the halfway point of the visual reveal.
func start_black_hole() -> void:
	if _active:
		return

	self.show()

	var tween := create_tween()
	tween.tween_method(set_shader_value, 0.0, 6.0, 6.0)

	# Start pulling at the halfway point (3 seconds in).
	# Using a parallel tween so the callback fires on its own timeline
	# while the shader tween continues uninterrupted.
	tween.parallel().tween_callback(func(): _active = true).set_delay(3.0)

func _physics_process(delta: float) -> void:
	if not _active:
		return

	for node in _attracted_nodes:
		if not is_instance_valid(node):
			continue

		var to_bh: Vector3 = global_position - node.global_position
		var dist: float = to_bh.length()

		if dist <= event_horizon_distance:
			_attracted_nodes.erase(node)
			node.queue_free()
			continue

		var dir: Vector3 = to_bh.normalized()
		var strength: float = pull_strength
		if inverse_distance:
			strength = pull_strength / max(dist, 0.5)

		node.global_position += dir * strength * delta

## Sets the "scale" shader uniform. Update the material path if your shader
## material isn't on this node directly (e.g., on a child MeshInstance3D).
func set_shader_value(value: float) -> void:
	var mat := self.get_active_material(0) as ShaderMaterial
	if mat:
		mat.set_shader_parameter("scale", value)
