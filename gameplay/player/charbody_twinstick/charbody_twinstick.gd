extends CharacterBody2D

@export var tractor_area: GravityField
@export var tractor_collision: CollisionPolygon2D
@export var cone_sprite: Sprite2D
@export var right_stick_aim: Node2D
@export var weapon_spawn: Marker2D
@export var player_hurtbox: Hurtbox

@export var thrust_force: float = 750.0
@export var impact_reduction: float = 800.0
@onready var control_disabled_timer: Timer = $ControlDisabledTimer


var disable_control: bool = false
var knockback_rotation_speed: float = 0.0
var gravity_cone_enabled: bool = false

var gravity_fields: Array[GravityField] = []

var health: int = 100: set = change_health

func _enter_tree() -> void:
  Game.player = self
  disable_cone()


func _ready() -> void:
  
  player_hurtbox.resolve_collision.connect(_resolve_collision, CONNECT_PERSIST)
  right_stick_aim.set_global_position(get_global_position())


func _physics_process(delta: float) -> void:
  
  var left_stick: Vector2 = Input.get_vector("Lstick_left", "Lstick_right", "Lstick_up", "Lstick_down")
  var right_stick: Vector2 = Input.get_vector("Rstick_left", "Rstick_right", "Rstick_up", "Rstick_down")
  
  if not right_stick.is_zero_approx():
    var target_angle = -right_stick.angle_to(Vector2.UP)
    var current_angle = right_stick_aim.get_global_rotation()
    right_stick_aim.set_global_rotation(lerp_angle(current_angle, target_angle, delta * 10))
  
  if Input.is_action_pressed("inverted_gravity"):
    tractor_area.invert_gravity = true
    enable_cone()
    cone_sprite.set_modulate(Color("1b05ff85"))
  elif Input.is_action_just_released("inverted_gravity"):
    tractor_area.invert_gravity = false
    disable_cone()
  
  if Input.is_action_pressed("fire") and not gravity_cone_enabled:
    enable_cone()
    cone_sprite.set_modulate(Color("ff052285"))
  elif Input.is_action_just_released("fire"):
    disable_cone()
  
  if not left_stick.is_zero_approx() and not disable_control:
    move_player(left_stick)
  else:
    velocity = velocity.move_toward(Vector2.ZERO, delta * 500.0)
  
  if knockback_rotation_speed > 0:
    if Collisions.is_relative_direction(velocity.normalized(), Vector2.RIGHT):
      rotation += delta * knockback_rotation_speed
    else:
      rotation -= delta * knockback_rotation_speed
    knockback_rotation_speed = move_toward(knockback_rotation_speed, 0, delta * 200)
  
  for field in gravity_fields:
    velocity += field.get_body_gravity(self)
  
  move_and_slide()
  right_stick_aim.set_global_position(get_global_position())

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
  
  if disable_control:
    velocity += added_velocity * 2.0
  else:
    velocity = added_velocity * 2.0
  
  disable_control = true
  control_disabled_timer.start()
  

func move_player(stick_input: Vector2) -> void:
  set_rotation(stick_input.angle_to(Vector2.UP) * -1)
  var facing: Vector2 = Vector2.UP.rotated(self.get_global_rotation()).normalized()
  velocity = facing * thrust_force
  knockback_rotation_speed = 0.0


func disable_cone() -> void:
  tractor_area._gravity_active = false
  tractor_collision.set_disabled(true)
  cone_sprite.set_visible(false)
  gravity_cone_enabled = false

func enable_cone() -> void:
  tractor_area._gravity_active = true
  tractor_collision.set_disabled(false)
  cone_sprite.set_visible(true)
  gravity_cone_enabled = true


func _resolve_collision(attackbox: AttackBox, _hurtbox: Hurtbox) -> void:
  if attackbox.get_collision_layer_value(8):
    Collisions.ballistic_collision(attackbox.get_parent(), self)
  elif attackbox.get_collision_layer_value(4):
    subtract_health(25)


func _on_control_disabled_timer_timeout() -> void:
  disable_control = false

func change_health(value: int) -> void:
  health = value

func subtract_health(amount: int) -> void:
  health -= amount
  print(health)
