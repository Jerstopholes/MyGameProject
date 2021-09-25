extends DebugCommand


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func define(arg):
	var _arg = get_parent().get_node(arg)
	if _arg:
		if _arg is DebugCommand:
			output_text(str("* * * [color=teal]", _arg._name, "[/color] * * *\n", _arg._desc))
	else:
		output_text(str('[color=red]ERROR[/color]: Could not define "', arg, '"!'))
		_arg = null
		return

