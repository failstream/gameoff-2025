## fixed_joint.gd

class_name FixedJoint
extends PinJoint2D
## Creates a pin joint that keeps the rotation of node b relative to node a.

## sets each body's rotation relative to the other body's rotation (needs implementation, may be unnecessary)
#@export var double_fixed: bool = false

var relative_rotation: float = 0.0


## connects [param body_a] with [param body_b] so that the rotation of [param body_b] keeps
## its rotation relative to [param body_a] from the initial connection.
func connect_bodies(body_a: PhysicsBody2D, body_b: PhysicsBody2D) -> void:
  
  node_a = body_a.get_path()
  node_b = body_b.get_path()
  
  var angle_to_body: float = (body_a.global_position - body_b.global_position).angle()
  relative_rotation = body_a.global_rotation - angle_to_body
  
  body_a.connect("tree_exiting", disconnect_joint)
  body_b.connect("tree_exiting", disconnect_joint)


func disconnect_joint() -> void:
  
  node_a = ""
  node_b = ""


func _physics_process(_delta: float) -> void:
  
  if node_a and node_b:
    var body_a: PhysicsBody2D = get_node(node_a)
    var body_b: PhysicsBody2D = get_node(node_b)
    if body_a and body_b:
      var angle_to_body: float = (body_a.global_position - body_b.global_position).angle()
      body_a.set_deferred("rotation", angle_to_body + relative_rotation)
    else:
      if not body_a:
        node_a = ""
      if not body_b:
        node_b = ""
