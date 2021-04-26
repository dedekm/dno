extends RigidBody

# constants
const Ladder = preload("res://src/Ladder.tscn")

# gameplay
export(int, 1, 10) var health := 2
export(int, 1, 10) var injured_height := 2
export(int, 1, 10) var killed_height := 4

# mouse sensitivity
export(float,0.1,1.0) var sensitivity_x = 0.5
export(float,0.1,1.0) var sensitivity_y = 0.4

# physics
export(float,1.0, 20.0) var speed = 10.0
export(float,1.0, 30.0) var jump_speed = 5

# instance refs
onready var level := get_parent()
onready var face := $Face
onready var hands := $Face/Hands
onready var camera := $Face/Camera
onready var ground_ray := $GroundRay
onready var ladder_timer := $LadderTimer

# variables
var mouse_motion := Vector2()
var on_ground := false
var last_solid_y_position : float

var ladder : Ladder

func _ready() -> void:
  last_solid_y_position = global_transform.origin.y
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  ground_ray.enabled = true
  pass

func _integrate_forces(_state: PhysicsDirectBodyState) -> void:
  var direction_force := get_direction_force()
  
  var just_landed : bool = ground_ray.is_colliding()
  if just_landed and !on_ground:
    var fallen_height := last_solid_y_position - global_transform.origin.y
    apply_fall_damage(fallen_height)

    print("jumped " + String(fallen_height))
    last_solid_y_position = global_transform.origin.y
  
  on_ground = just_landed

  var jumping := 0
  if Input.is_action_just_pressed("jump") and on_ground:
    jumping = 1

  set_axis_velocity(Vector3(0, jumping * jump_speed, 0))
  add_force(direction_force, Vector3(0, 0, 0))

func _physics_process(delta: float) -> void:
  # camera rotation
  camera.rotate_x(deg2rad(20) * - mouse_motion.y * sensitivity_y * delta)
  camera.rotation.x = clamp(camera.rotation.x, deg2rad(-47), deg2rad(47))
  face.rotate_y(deg2rad(20)* - mouse_motion.x * sensitivity_x * delta)

  mouse_motion = Vector2()

  pass

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    mouse_motion = event.relative

  if event is InputEventMouseButton:
    if event.pressed:
      ladder = Ladder.instance()
      ladder.mode = RigidBody.MODE_STATIC
      ladder.visible = true
      ladder.rotation_degrees.x = 20
      ladder.translation.z = -1
      hands.add_child(ladder)

      ladder_timer.connect("timeout", self, "add_ladder_part")
      ladder_timer.set_wait_time(0.3)
      ladder_timer.start()
    else:
      if ladder:
        var t := ladder.global_transform
        hands.remove_child(ladder)
        get_parent().add_child(ladder)
        ladder.transform = t
        ladder.mode = RigidBody.MODE_RIGID
        ladder_timer.stop()
        ladder = null

func add_ladder_part() -> void:
  if ladder:
    ladder.add_part()
    
func apply_fall_damage(height: float) -> void:
  var h := health

  if height >= killed_height:
    level.add_red_filter(0.9)
    h = 0
  elif height >= injured_height:
    h -= 1
    
  if h <= 0:
    # killed
    level.add_red_filter(0.9)
  elif h != health:
    # injured
    level.add_red_filter(0.3)   
  
  health = h

func get_direction_force() -> Vector3:
  var m := Vector3()

  if Input.is_action_pressed("ui_up"):
    m.z -= 1
  if Input.is_action_pressed("ui_down"):
    m.z += 1
  if Input.is_action_pressed("ui_left"):
    m.x -= 1
  if Input.is_action_pressed("ui_right"):
    m.x += 1

  # multiply movement by speed & rotate in direction of camera
  return Vector3(m.x * speed, 0, m.z * speed).rotated(Vector3(0, 1, 0), face.rotation.y)
