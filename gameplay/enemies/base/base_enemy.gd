extends CharacterBody2D

@onready var hurtbox: Hurtbox = $Hurtbox

@export var max_speed: float = 600.0
@export var acceleration: float = 900

var knocked_back: bool = false
var knockback_rotation_speed: float = 0.0

var health: int = 100: set = change_health

func _ready() -> void:
  
  hurtbox.resolve_collision.connect(_got_hurt, CONNECT_PERSIST)
  


func _physics_process(delta: float) -> void:
  
  var distance_to_player: float = global_position.distance_to(Game.player.global_position)
  var direction_to_player: Vector2 = global_position.direction_to(Game.player.global_position)
  velocity = velocity.move_toward(direction_to_player * max_speed, (acceleration + distance_to_player) * delta)
  
  move_and_slide()


func _got_hurt(attack_area: AttackBox, _hurt_area: Hurtbox) -> void:
  if attack_area.get_collision_layer_value(8):
    Collisions.ballistic_collision(attack_area.get_parent(), self)


func knockback(direction: Vector2, speed: float, impact_velocity: float) -> void:
  if is_zero_approx(impact_velocity):
    return
  var added_velocity: Vector2 = Vector2.ZERO
  if impact_velocity > 2000.0:
    added_velocity = direction * 2000
    knockback_rotation_speed = 50.0
    subtract_health(50)
  elif impact_velocity < 200.0:
    added_velocity = direction * 200.0
    knockback_rotation_speed = 20.0
    subtract_health(10)
  else:
    added_velocity = direction * speed
    knockback_rotation_speed = Collisions.scalef(speed, 200.0, 2000.0, 20.0, 50.0)
    subtract_health(25)
  
  velocity += added_velocity * 2.0


func change_health(value: int) -> void:
  health = value
  modulate.g = Collisions.scalef(health as float, 0.0, 100.0, 0.0, 1.0)
  modulate.b = Collisions.scalef(health as float, 0.0, 100.0, 0.0, 1.0)


func subtract_health(amount: int) -> void:
  health -= amount
  if health <= 0:
    queue_free()
