extends Spatial
class_name Ladder

const PLANK_LENGTH = 0.275

export var length := 1

# instance refs
onready var collission_shape := $CollisionShape
onready var plank_mesh := $PlankMesh

func add_part() -> void:
  var dup = CollisionShape
  dup = collission_shape.duplicate()
  dup.translation.z -= length * PLANK_LENGTH
  add_child(dup)
  
  var dup_plank = Spatial
  dup_plank = plank_mesh.duplicate()
  dup_plank.translation.z -= length * PLANK_LENGTH
  add_child(dup_plank)
  
  length += 1

func _physics_process(_delta: float) -> void:
  if translation.y < -50:
    print("deleted")
    queue_free()

  pass
