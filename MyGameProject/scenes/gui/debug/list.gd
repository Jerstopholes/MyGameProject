extends DebugCommand

func list():
	executed = false
	for i in console.get_child_count():
		if console.get_child(i) is DebugCommand:
			output_text(str("[color=teal]", console.get_child(i)._name,"[/color]\n", console.get_child(i)._desc))
	
	debug_log("Succesfully listed all currently available and valid commands.")
	executed = true
