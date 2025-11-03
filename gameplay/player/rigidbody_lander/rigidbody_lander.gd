extends RigidBody2D

@onready var left_engine: CollisionShape2D = $LeftEngine
@onready var right_engine: CollisionShape2D = $RightEngine
@onready var left_marker: Marker2D = $LeftEngine/LeftMarker
@onready var right_marker: Marker2D = $RightEngine/RightMarker
@onready var left_flame: Sprite2D = $LeftEngine/LeftFlame
@onready var right_flame: Sprite2D = $RightEngine/RightFlame


@export var force: float = 500.0

func _ready() -> void:
  Game.player = self


func _physics_process(delta: float) -> void:
  
  if Input.is_action_pressed("Left"):
    var facing = Vector2.UP.rotated(get_global_rotation())
    apply_force(facing * force, left_marker.global_position)
    left_flame.set_visible(true)
  if Input.is_action_pressed("Right"):
    var facing = Vector2.UP.rotated(get_global_rotation())
    apply_force(facing * force, right_marker.global_position)
    right_flame.set_visible(true)
  
  if Input.is_action_just_released("Left"):
    left_flame.set_visible(false)
  if Input.is_action_just_released("Right"):
    right_flame.set_visible(false)
