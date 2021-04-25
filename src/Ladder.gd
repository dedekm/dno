extends Spatial
class_name Ladder

export var length := 1

# instance refs
onready var collission_shape := $CollisionShape
onready var plank_parent := $PlankParent

func add_part() -> void:


  var dup = CollisionShape
  dup = collission_shape.duplicate()
  dup.translation.z -= length
  add_child(dup)
  
  var dup_plank = Spatial
  dup_plank = plank_parent.duplicate()
  dup_plank.translation.z -= length
  add_child(dup_plank)
  
  length += 1
