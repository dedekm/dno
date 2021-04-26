extends Spatial

var playable := true

onready var env : Environment = $WorldEnvironment.environment
onready var red_fade_out := $RedFadeOut

var filter_color := Color(1, 1, 1, 1)

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

  pass

func _process(_delta: float) -> void:
  if filter_color:
    env.adjustment_color_correction.gradient.colors[1] = filter_color

  pass

func _input(_event: InputEvent) -> void:
  if Input.is_action_just_pressed("ui_cancel"):
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func add_red_filter(level: float) -> void:
  env.adjustment_enabled = true
  level = 1 - level
  red_fade_out.interpolate_property(self,
                                    "filter_color",
                                    filter_color,
                                    Color(1, level, level, 1),
                                    2.0,
                                    Tween.TRANS_ELASTIC,
                                    Tween.EASE_OUT)

  red_fade_out.start()
