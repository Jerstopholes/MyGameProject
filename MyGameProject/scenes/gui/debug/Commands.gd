extends Node

export (NodePath) var output
export (NodePath) var input


var _output
var _input


func _ready():
	if output:
		_output = get_node(output)
	else:
		printerr("NO OUTPUT IS ASSIGNED!")
		get_tree().quit()
	if input:
		_input = get_node(input)
	else:
		printerr("NO INPUT IS ASSIGNED!")
		get_tree().quit()
