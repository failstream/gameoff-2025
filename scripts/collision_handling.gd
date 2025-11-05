class_name Collisions



static func ballistic_collision(ballistic: CharacterBody2D, body: CharacterBody2D) -> void:
  var normal: Vector2 = (body.get_global_position() - ballistic.get_global_position()).normalized()
  var impact_speed: float = ballistic.velocity.dot(normal)
  var ballistic_velocity: float = ballistic.velocity.length()
  if "knockback" in body:
    body.knockback(normal, impact_speed, ballistic_velocity)
    return


## Checks if two vectors are moving in the same direction relative to the threshold
static func is_relative_direction(vec1: Vector2, vec2: Vector2, threshold_degrees: float = 0) -> bool:

  var threshold = deg_to_rad(threshold_degrees)
  var normal1 = vec1.normalized()
  var normal2 = vec2.normalized()
  var dot_product = normal1.dot(normal2)
  return dot_product > threshold


## Takes a value that is currently on one range and converts it to a different range.
static func scalef(value: float, old_min: float, old_max: float, new_min: float, new_max: float) -> float:

  var old_range = old_max - old_min
  var new_range = new_max - new_min
  return (((value - old_min) * new_range) / old_range) + new_min
