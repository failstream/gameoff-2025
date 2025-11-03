## hurtbox.gd

class_name Hurtbox
extends Area2D
## An extension of Area2D that acts as a hurtbox when a hitbox enters it. Emits the appropriate signal that can
## be connected to from the base object.


## emitted by the attackbox when it detects this hurtbox. Connect in base object to desired collision handling function
signal resolve_collision(AttackBox, Hurtbox)


func _enter_tree() -> void:
  
  monitorable = true
  monitoring = false
