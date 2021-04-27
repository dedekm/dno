extends Popup

onready var player = get_node("/root/Level/Character")
var already_paused
var selected_menu
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    player = get_node("/root/Level/Character") # Replace with function body.

func change_menu_color():
    $Resume/ResumeLabel.set("custom_colors/font_color", Color.gray)
    $Restart/RestartLabel.set("custom_colors/font_color", Color.gray)
    $Quit/QuitLabel.set("custom_colors/font_color", Color.gray)
    
    match selected_menu:
        0:
            $Resume/ResumeLabel.set("custom_colors/font_color", Color(1,1,1))
        1:
            $Restart/RestartLabel.set("custom_colors/font_color", Color(1,1,1))
        2:
            $Quit/QuitLabel.set("custom_colors/font_color", Color(1,1,1))
            
            
            
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
        elif Input.is_action_just_pressed("jump"):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
