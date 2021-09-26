extends DebugCommand


func define(arg):
	executed = false
	var _arg
	var found = false
	for i in console.get_child_count():
		if console.get_child(i) is DebugCommand:
			if console.get_child(i).name == arg:
				_arg = console.get_node(arg)
				found = true

	
				output_text(str("[color=teal]", _arg._name, "[/color]\n", _arg._desc))
				debug_log("Succesfully defined " + _arg.name + "!")
				executed = true

	if not found:
		output_text(str(error, 'Could not define "', arg, '"!'))
		_arg = null
		executed = false
		return

