
extends RigidBody2D


@export var thrust_speed: float = 300.0
@export var rotation_speed: float = 5000.0


var player: RigidBody2D
var mouse_position: Vector2 = Vector2.ZERO


func _ready() -> void:
  player = Game.player
  var direction_to_target = (player.global_position - global_position).normalized()
  set_global_rotation(Vector2.UP.angle_to(direction_to_target))


func _physics_process(_delta: float) -> void:
  
  var direction_to_target = (_get_point_in_front_of_player() - global_position).normalized()
  var forward_direction = -transform.y
  var angle_diff = forward_direction.angle_to(direction_to_target)
  apply_torque(angle_diff * rotation_speed)
  
  apply_central_force(forward_direction * thrust_speed)
  


func _get_point_in_front_of_player() -> Vector2:
  var point: Vector2
  var distance: float = player.get_global_position().distance_to(global_position)
  point = player.get_global_position() + player.get_linear_velocity().normalized() * distance / 2
  
  return point
