extends StaticBody2D

@onready var gravity_area: Area2D = $GravityArea
@onready var gravity_area_collision_shape: CollisionShape2D = $GravityArea/GravityAreaCollisionShape
@onready var time_between_firing: Timer = $TimeBetweenFiring
@onready var time_growth: Timer = $TimeGrowth
@onready var time_at_max: Timer = $TimeAtMax


const GROWTH_RATE: float = 120.0

func _ready() -> void:
  time_between_firing.start()


func _physics_process(delta: float) -> void:
  
  if not time_between_firing.is_stopped():
    return
  
  if not time_growth.is_stopped():
    increase_gravity_area_size(delta)


func increase_gravity_area_size(delta: float) -> void:
  gravity_area_collision_shape.shape.radius += delta * GROWTH_RATE


func remove_gravity_shape() -> void:
  gravity_area_collision_shape.shape.radius = 10.0


func _on_time_between_firing_timeout() -> void:
  time_growth.start()


func _on_time_growth_timeout() -> void:
  time_at_max.start()


func _on_time_at_max_timeout() -> void:
  remove_gravity_shape()
  time_between_firing.start()
