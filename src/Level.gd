extends Spatial

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  pass

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed("ui_cancel"):
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
