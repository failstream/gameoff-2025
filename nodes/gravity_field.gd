## gravity_field.gd

class_name GravityField
extends Area2D
## This area has an additional gravity resource so that it can apply its gravity properties to
## CharacterBody2D as well as RigidBody2D. The CharacterBody2D must have a variable called
## "gravity_fields" that is an Array[GravityField]. 


## contains the gravity calculated for each body that this gravity field is affecting.
var applied_gravity: Dictionary[CharacterBody2D, Vector2] = {}

## contains a boolean for each body that determines if the gravity field is increasing the applied
## gravity or decreasing it.
var increasing_gravity: Dictionary[CharacterBody2D, bool] = {}

## contains each valid CharacterBody2D that is within the area currently.
var bodies_within_area: Array[CharacterBody2D] = []

## used to hold the initial gravity_point_center value as an offset for the global_position for moving
## gravity fields.
var gravity_point_offset: Vector2 = Vector2.ZERO

## custom gravity center variable for CharacterBody2D so that the default variable isn't overridden as
## that breaks behavior with RigidBody2D for some reason.
var custom_gravity_center: Vector2 = Vector2.ZERO

## Used to calculate how fast gravity goes to zero while increasing_gravity is false. Should change
## this to export and/or make the function customizable somehow.
const GRAVITY_FALLOFF: float = 300.0

## Determines if the gravity is active for this GravityField or not.
var _gravity_active: bool = true:
  set(value):
    _gravity_active = value
    if not _gravity_active:
      for body in increasing_gravity.keys():
        increasing_gravity[body] = false
    else:
      for body in bodies_within_area:
        if increasing_gravity.has(body):
          increasing_gravity[body] = true
        else:
          _add_body(body)


func _ready() -> void:
  
  connect("body_entered", _body_entered, CONNECT_PERSIST)
  connect("body_exited", _body_exited, CONNECT_PERSIST)
  # uses default gravity_point_center as an offset to the global_position
  gravity_point_offset = get_gravity_point_center()
  custom_gravity_center = global_position + gravity_point_offset


## Connected to body_entered signal on ready
func _body_entered(body: PhysicsBody2D) -> void:
  
  # add to bodies_within_area if it is a valid body regardless of anything else
  if _is_valid_body(body) and not bodies_within_area.has(body):
    bodies_within_area.append(body)
  
  # if this area can't add new bodies no need to continue
  if not _gravity_active or not _is_valid_body(body):
    return
  
  if applied_gravity.has(body):
    increasing_gravity[body as CharacterBody2D] = true
  else:
    _add_body(body)


## connected to body_exited signal on ready
func _body_exited(body: PhysicsBody2D) -> void:
  
  if not _is_valid_body(body):
    return
  
  if bodies_within_area.has(body):
    bodies_within_area.remove_at(bodies_within_area.find(body))
  if applied_gravity.has(body as CharacterBody2D):
    increasing_gravity[body as CharacterBody2D] = false



func _physics_process(delta: float) -> void:
  
  # ensure the gravity_point_center is reset in case the gravity field moved.
  custom_gravity_center = global_position + gravity_point_offset
  #set_gravity_point_center(global_position + gravity_point_offset)
  for body in applied_gravity.keys():
    if body:
      _step_gravity(delta, body)
      if applied_gravity[body].is_zero_approx() and not increasing_gravity[body]:
        _remove_body(body)
    else:
      # body is no longer a valid instance
      _remove_body(body)


func _is_valid_body(body: PhysicsBody2D) -> bool:
  return body and body is CharacterBody2D and "gravity_fields" in body


## gets the calculated gravity for the character from [member applied_gravity].
func get_body_gravity(body: CharacterBody2D) -> Vector2:
  
  if not body or not applied_gravity.has(body) or not increasing_gravity.has(body):
    return Vector2.ZERO
  return applied_gravity[body]


func reset_body_gravity(body: CharacterBody2D) -> void:
  
  if not body or not applied_gravity.has(body) or not increasing_gravity.has(body):
    return
  applied_gravity[body] = Vector2.ZERO


## adds this body to the gravity calculations.
func _add_body(body: CharacterBody2D) -> void:
  applied_gravity[body] = Vector2.ZERO
  increasing_gravity[body] = true
  if not body.gravity_fields.has(self):
    body.gravity_fields.append(self)


## immediately removes this body from all gravity calculations.
func _remove_body(body: CharacterBody2D) -> void:
  applied_gravity.erase(body)
  increasing_gravity.erase(body)
  if _is_valid_body(body):
    body.gravity_fields.erase(self)


## steps gravity in [member applied_gravity] for the [param body] forward one frame.
func _step_gravity(delta: float, body: CharacterBody2D) -> void:
  
  if gravity_point:
    _step_gravity_point(delta, body)
  else:
    _step_gravity_direction(delta, body)


## steps forward using the direction variable
func _step_gravity_direction(delta: float, body: CharacterBody2D) -> void:
  
  if increasing_gravity[body]:
    applied_gravity[body] = applied_gravity[body].move_toward(gravity_direction * gravity, gravity * delta)
  elif not increasing_gravity[body] and not applied_gravity[body].is_zero_approx():
    _diminish_gravity(delta, body)


## steps forward one frame using a gravity point.
func _step_gravity_point(delta: float, body: CharacterBody2D) -> void:
  
  var current_gravity_direction: Vector2 = body.global_position.direction_to(custom_gravity_center)
  var distance: float = body.global_position.distance_to(custom_gravity_center)
  var force: float = gravity
  if gravity_point_unit_distance > 0.0 and not is_zero_approx(gravity_point_unit_distance):
    force =  gravity / (distance / abs(gravity_point_unit_distance))
  
  if increasing_gravity[body]:
    applied_gravity[body] = applied_gravity[body].move_toward(current_gravity_direction * force, force * delta)
  elif not increasing_gravity[body] and not applied_gravity[body].is_zero_approx():
    _diminish_gravity(delta, body)


## removes gravity from [member applied_gravity] one step.
func _diminish_gravity(delta: float, body: CharacterBody2D) -> void:
  applied_gravity[body] = applied_gravity[body].move_toward(Vector2.ZERO, GRAVITY_FALLOFF * delta)
