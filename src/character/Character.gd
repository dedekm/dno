extends KinematicBody

# constants
const GRAVITY = 9.8
const Ladder = preload("res://src/Ladder.tscn")

# mouse sensitivity
export(float,0.1,1.0) var sensitivity_x = 0.5
export(float,0.1,1.0) var sensitivity_y = 0.4

# physics
export(float,1.0, 20.0) var speed = 5.0
export(float,1.0, 30.0) var jump_height = 5
export(float,1.0, 10.0) var mass = 2.0
export(float,0.1, 3.0, 0.1) var gravity_scl = 1.0

# instance refs
onready var player_cam := $Camera
onready var ground_ray := $GroundRay
onready var ladder_timer := $LadderTimer

# variables
var mouse_motion := Vector2()
var gravity_speed := 0.0

var ladder : Ladder

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  ground_ray.enabled = true
  pass

func _physics_process(delta: float) -> void:
  # camera and body rotation
  rotate_y(deg2rad(20)* - mouse_motion.x * sensitivity_x * delta)
  player_cam.rotate_x(deg2rad(20) * - mouse_motion.y * sensitivity_y * delta)
  player_cam.rotation.x = clamp(player_cam.rotation.x, deg2rad(-47), deg2rad(47))
  mouse_motion = Vector2()
  
  # gravity
  gravity_speed -= GRAVITY * gravity_scl * mass * delta
  
  # character movement
  var velocity := Vector3()
  velocity = _axis() * speed
  velocity.y = gravity_speed
  
  # jump
  if Input.is_action_just_pressed("space") and ground_ray.is_colliding():
    velocity.y = jump_height
  
  gravity_speed = move_and_slide(velocity).y
  
  pass

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    mouse_motion = event.relative

  if event is InputEventMouseButton:
    if event.pressed:
      ladder = Ladder.instance()
      ladder.mode = RigidBody.MODE_STATIC
      ladder.visible = true
      ladder.rotation_degrees.x = 30
      ladder.translation.y = 0.8
      ladder.translation.z = -1
      add_child(ladder)
      
      ladder_timer.connect("timeout", ladder, "add_part")
      ladder_timer.set_wait_time(0.5)
      ladder_timer.start()
    else:
      if ladder:
        var t := ladder.global_transform
        remove_child(ladder)
        get_parent().add_child(ladder)
        ladder.transform = t
        ladder.mode = RigidBody.MODE_RIGID
        ladder_timer.stop()

func _axis() -> Vector3:
  var direction := Vector3()
  
  if Input.is_key_pressed(KEY_W):
    direction -= get_global_transform().basis.z.normalized()
    
  if Input.is_key_pressed(KEY_S):
    direction += get_global_transform().basis.z.normalized()
    
  if Input.is_key_pressed(KEY_A):
    direction -= get_global_transform().basis.x.normalized()
    
  if Input.is_key_pressed(KEY_D):
    direction += get_global_transform().basis.x.normalized()

  return direction.normalized()
