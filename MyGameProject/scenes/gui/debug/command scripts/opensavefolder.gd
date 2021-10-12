extends DebugCommand

func _ready():
	_desc = str("Opens the file explorer to the saves folder (stored in [color=green]",
	OS.get_user_data_dir(),"/saves[/color]).")


func opensavefolder():
	executed = false
	OS.shell_open(OS.get_user_data_dir()+"/saves")
	executed = true
