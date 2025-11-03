## ballistic_projectile.gd

class_name BallisticProjectile
extends CharacterBody2D
## This is a projectile that should be permanently spawned for the player. Player uses gravity field to control it.
## The projectile will smash through enemies doing damage using a hurtbox along the way.

@export var hitbox: Area2D

var gravity_fields: Array[GravityField] = []

var reflection_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
  
  if not reflection_velocity.is_zero_approx():
    reflection_velocity = reflection_velocity.move_toward(Vector2.ZERO, delta * 100.0)
  else:
    reflection_velocity = Vector2.ZERO
  
  velocity = reflection_velocity
  
  for field in gravity_fields:
    velocity += field.get_body_gravity(self)
  
  var prior_velocity: Vector2 = velocity
  move_and_slide()
  
  for i in get_slide_collision_count():
    var collision: KinematicCollision2D = get_slide_collision(i)
    var normal: Vector2 = collision.get_normal()
    reflection_velocity = prior_velocity.bounce(normal)
    for field in gravity_fields:
      field.reset_body_gravity(self)
