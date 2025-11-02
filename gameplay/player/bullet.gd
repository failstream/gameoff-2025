extends Area2D

var _current_direction: Vector2 = Vector2.ZERO
var _current_speed: float = 0.0

var travel_distance: float = 0.0
const MAX_TRAVEL: float = 2000.0

func _physics_process(delta: float) -> void:
  
  if is_zero_approx((_current_direction * _current_speed).length_squared()):
    return
  position += _current_direction * _current_speed * delta
  travel_distance += _current_speed * delta
  if MAX_TRAVEL < travel_distance:
    queue_free()


func fire(initial_direction: Vector2, initial_speed: float) -> void:
  _current_direction = initial_direction
  _current_speed = initial_speed


func _on_body_entered(body: Node2D) -> void:
  if body is StaticBody2D:
    body.queue_free()
