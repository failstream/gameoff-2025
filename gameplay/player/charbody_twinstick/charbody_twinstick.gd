extends CharacterBody2D

@onready var tractor_area: GravityField = $TractorArea
@onready var tractor_collision: CollisionPolygon2D = $TractorArea/TractorCollision
@onready var cone_sprite: Sprite2D = $TractorArea/ConeSprite

@export var thrust_force: float = 350.0

var gravity_cone_enabled: bool = false

var gravity_fields: Array[GravityField] = []

func _enter_tree() -> void:
  Game.player = self


func _physics_process(delta: float) -> void:
  
  var left_stick: Vector2 = Input.get_vector("Lstick_left", "Lstick_right", "Lstick_up", "Lstick_down")
  var right_stick: Vector2 = Input.get_vector("Rstick_left", "Rstick_right", "Rstick_up", "Rstick_down")
  
  if right_stick.is_zero_approx():
    disable_cone()
  else:
    tractor_area.set_global_rotation(right_stick.angle_to(Vector2.UP) * -1)
    if not gravity_cone_enabled:
      enable_cone()
  
  if not left_stick.is_zero_approx():
    move_player(left_stick)
  else:
    velocity = velocity.move_toward(Vector2.ZERO, delta * 500.0)
  
  for field in gravity_fields:
    velocity += field.get_body_gravity(self)
  
  move_and_slide()

func move_player(stick_input: Vector2) -> void:
  set_rotation(stick_input.angle_to(Vector2.UP) * -1)
  var facing: Vector2 = Vector2.UP.rotated(self.get_global_rotation()).normalized()
  velocity = facing * thrust_force

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
