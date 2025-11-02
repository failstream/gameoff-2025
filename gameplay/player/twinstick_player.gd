extends RigidBody2D

@export var thrust_force: float = 200.0

@onready var area_2d: Area2D = $Area2D
@onready var cone_sprite: Sprite2D = $Area2D/ConeSprite
@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D

var gravity_cone_enabled: bool = false

func _enter_tree() -> void:
  Game.player = self


func _physics_process(delta: float) -> void:
  var left_stick: Vector2 = Input.get_vector("Lstick_left", "Lstick_right", "Lstick_up", "Lstick_down")
  var right_stick: Vector2 = Input.get_vector("Rstick_left", "Rstick_right", "Rstick_up", "Rstick_down")
  
  if right_stick.is_zero_approx():
    disable_cone()
  else:
    area_2d.set_global_rotation(right_stick.angle_to(Vector2.UP) * -1)
    if not gravity_cone_enabled:
      enable_cone()
  
  if not left_stick.is_zero_approx():
    move_player(left_stick)


func move_player(stick_input: Vector2) -> void:
  set_rotation(stick_input.angle_to(Vector2.UP) * -1)
  var facing = Vector2.UP.rotated(self.get_global_rotation())
  self.apply_central_force(facing * thrust_force)

func disable_cone() -> void:
  collision_polygon_2d.set_disabled(true)
  cone_sprite.set_visible(false)
  gravity_cone_enabled = false


func enable_cone() -> void:
  collision_polygon_2d.set_disabled(false)
  cone_sprite.set_visible(true)
  gravity_cone_enabled = true
