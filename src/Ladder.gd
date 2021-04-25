extends Spatial

export var length := 1

# instance refs
onready var collission_shape := $CollisionShape
onready var plank_parent := $PlankParent

func _ready() -> void:
  print(length)
  if length > 1:
    for l in range(1, length):
      var dup = CollisionShape
      dup = collission_shape.duplicate()
      dup.translation.x += l
      add_child(dup)
      
      var dup_plank = Spatial
      dup_plank = plank_parent.duplicate()
      dup_plank.translation.x += l
      add_child(dup_plank)
  pass
