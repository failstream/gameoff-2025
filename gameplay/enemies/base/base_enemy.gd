extends CharacterBody2D

@onready var hurtbox: Hurtbox = $Hurtbox

@export var max_speed: float = 500.0
@export var acceleration: float = 800

func _ready() -> void:
  
  hurtbox.resolve_collision.connect(_got_hurt, CONNECT_PERSIST)
  


func _physics_process(delta: float) -> void:
  
  var distance_to_player: float = global_position.distance_to(Game.player.global_position)
  var direction_to_player: Vector2 = global_position.direction_to(Game.player.global_position)
  velocity = velocity.move_toward(direction_to_player * max_speed, (acceleration + distance_to_player) * delta)
  
  move_and_slide()


func _got_hurt(attack_area: AttackBox, hurt_area: Hurtbox) -> void:
  print("ENEMY OUCH!")
