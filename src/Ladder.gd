extends Spatial
class_name Ladder

const PLANK_LENGTH = 0.275

export var length := 1

# instance refs
onready var body := $LadderBody
onready var collission_shape := $LadderBody/CollisionShape
onready var planks := $LadderBody/Planks
onready var plank_mesh := $LadderBody/Planks/PlankMesh

func _ready() -> void:
  body.mode = RigidBody.MODE_STATIC
  rotation_degrees.x = 20
  translation.z = -1
  pass

func add_part() -> void:
  collission_shape.shape = collission_shape.shape.duplicate()
  collission_shape.shape.extents.x += 0.275 / 2
  
  var dup_plank = MeshInstance
  dup_plank = plank_mesh.duplicate()
  dup_plank.translation.x += length * PLANK_LENGTH
  planks.add_child(dup_plank)

  planks.translation.z += PLANK_LENGTH / 2
  body.translation.z -= PLANK_LENGTH / 2
  
  length += 1

func _process(_delta: float) -> void:
  if body.global_transform.origin.y < -50:
    queue_free()

  pass
