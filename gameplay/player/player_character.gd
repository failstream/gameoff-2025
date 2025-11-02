extends RigidBody2D


var direction_input: int = 0
var thrust_input: int = 0

const ROTATIONAL_FORCE: float = 3000.0
const THRUST_FORCE: float = 500.0

@export var bullet_scene: PackedScene

func _enter_tree() -> void:
  Game.player = self


func _physics_process(_delta: float) -> void:
  
  direction_input = 0
  thrust_input = 0
  if Input.is_action_pressed("Left"):
    direction_input -= 1
  if Input.is_action_pressed("Right"):
    direction_input += 1
  if Input.is_action_pressed("Thrust"):
    thrust_input += 1
  
  if Input.is_action_just_pressed("fire"):
    fire_bullet()
  
  if direction_input != 0:
    self.apply_torque(direction_input * ROTATIONAL_FORCE)
  if thrust_input != 0:
    var facing = Vector2.UP.rotated(self.get_global_rotation())
    self.apply_central_force(facing * THRUST_FORCE)


func fire_bullet() -> void:
  var bullet_instance = bullet_scene.instantiate()
  bullet_instance.global_position = global_position
  bullet_instance.fire(Vector2.UP.rotated(self.get_global_rotation()), 1000.0)
  add_child(bullet_instance)
  
