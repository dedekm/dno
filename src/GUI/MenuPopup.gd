extends Popup

onready var player = get_node("/root/Level/Character")
var already_paused : bool
var selected_menu : int

func _ready():
    player = get_node("/root/Level/Character")

func change_menu_color():
    $ColorRect/ResumeLabel.set("custom_colors/font_color", Color.gray)
    $ColorRect/RestartLabel.set("custom_colors/font_color", Color.gray)
    $ColorRect/QuitLabel.set("custom_colors/font_color", Color.gray)
    
    match selected_menu:
        0:
            $ColorRect/ResumeLabel.set("custom_colors/font_color", Color(1,1,1))
        1:
            $ColorRect/RestartLabel.set("custom_colors/font_color", Color(1,1,1))
        2:
            $ColorRect/QuitLabel.set("custom_colors/font_color", Color(1,1,1))

func _input(event):
    if not visible:
        if Input.is_action_just_pressed("menu"):
            # Pause game
            already_paused = get_tree().paused
            get_tree().paused = true
            # Reset the popup
            selected_menu = 0
            change_menu_color()
            # Show popup
            player.set_process_input(false)
            
            var x : float = (get_viewport_rect().size.x - 200) / 2
            var y : float = (get_viewport_rect().size.y - 100) / 2
            $ColorRect.margin_left = x
            $ColorRect.margin_right = x + 200
            $ColorRect.margin_top = y
            $ColorRect.margin_bottom = y + 100
            
            
            popup()
    else:
        if Input.is_action_just_pressed("ui_down"):
            selected_menu = (selected_menu + 1) % 3;
            change_menu_color()
        elif Input.is_action_just_pressed("ui_up"):
            if selected_menu > 0:
                selected_menu = selected_menu - 1
            else:
                selected_menu = 2
            change_menu_color()
        elif Input.is_action_just_pressed("ui_accept"):
            match selected_menu:
                0:
                    # Resume game
                    if not already_paused:
                        get_tree().paused = false
                    player.set_process_input(true)
                    hide()
                1:
                    # Restart game
                    get_tree().change_scene("res://src/Level.tscn")
                    get_tree().paused = false
                2:
                    # Quit game
                    get_tree().quit()
