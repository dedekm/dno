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
export(float,1.0, 20.0) var speed = 8.0
export(float,1.0, 30.0) var jump_speed = 4

# instance refs
onready var level := get_parent()
onready var face := $Face
onready var hands := $Face/Hands
onready var camera := $Face/Camera
onready var ground_ray := $GroundRay
onready var ladder_timer := $LadderTimer
onready var water_sounds_timer : Timer
onready var sounds := $Sounds
onready var water_sounds := $Sounds/WaterDropsSounds

# variables
var mouse_motion := Vector2()
var on_ground := false
var last_solid_y_position : float

var ladder : Ladder

func _ready() -> void:
  last_solid_y_position = global_transform.origin.y
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  ground_ray.enabled = true
  
  water_sounds_timer = Timer.new()
  water_sounds_timer.one_shot = true
  water_sounds_timer.connect("timeout", self, "play_water_sound")
  water_sounds_timer.set_wait_time(1)
  add_child(water_sounds_timer)
  water_sounds_timer.start()

  water_sounds.get_node("Timer").connect("timeout", water_sounds, "stop")
  
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
  var rot_x : float = deg2rad(20) * - mouse_motion.y * sensitivity_y * delta
  camera.rotate_x(rot_x)
  camera.rotation.x = clamp(camera.rotation.x, deg2rad(-47), deg2rad(47))
  hands.rotate_x(rot_x)
  hands.rotation.x = clamp(camera.rotation.x, deg2rad(-20), deg2rad(20))
  
  face.rotate_y(deg2rad(20)* - mouse_motion.x * sensitivity_x * delta)

  mouse_motion = Vector2()
  
  if global_transform.origin.y < -50:
    die()

  pass

func _input(event: InputEvent) -> void:
  if !level.playable:
    return

  if event is InputEventMouseMotion:
    mouse_motion = event.relative

  if event is InputEventMouseButton:
    if event.pressed:
      ladder = Ladder.instance()
      hands.add_child(ladder)

      ladder_timer.connect("timeout", self, "add_ladder_part")
      ladder_timer.set_wait_time(0.3)
      ladder_timer.start()
    else:
      if ladder and level.playable:
        var t := ladder.global_transform
        hands.remove_child(ladder)
        get_parent().add_child(ladder)
        ladder.transform = t
        ladder.body.mode = RigidBody.MODE_RIGID
        ladder_timer.stop()
        ladder = null

func add_ladder_part() -> void:
  if !level.playable:
    return

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
    die()
  elif h != health:
    # injured
    level.add_red_filter(0.3)   
  
  health = h


func die() -> void:
  level.add_red_filter(0.9)
  level.playable = false
  
  var die_tween := Tween.new()
  die_tween.interpolate_property(face,
                                 "translation",
                                  face.translation,
                                  Vector3(face.translation.x, 0.6, face.translation.z),
                                  3.5,
                                  Tween.TRANS_EXPO,
                                  Tween.EASE_OUT)
  add_child(die_tween)
  die_tween.start()
  
func play_water_sound() -> void:
  sounds.rotation_degrees = Vector3(360 * randf(), 360 * randf(), 360 * randf())
  water_sounds.translation.x = rand_range(2, 8)
  water_sounds.play(0.5 * rand_range(1, 7))
  water_sounds_timer.set_wait_time(3 + randf() * 7)
  water_sounds_timer.start()
  water_sounds.get_node("Timer").start()

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
