## attack_box.gd


class_name AttackBox
extends Area2D
## An extension of Area2D that sets itself up as an AttackBox. Only detects Hurtboxes.


func _enter_tree() -> void:
  
  monitorable = false
  monitoring = true


func _ready() -> void:
  
  connect("area_entered", _area_entered, CONNECT_PERSIST)


func _area_entered(area: Area2D) -> void:
  
  assert(area is Hurtbox)
  area.resolve_collision.emit(self, area)
