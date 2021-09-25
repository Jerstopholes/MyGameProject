extends Node

class_name DebugCommand, "res://assets/icons/DebugConsoleIcon.png"

# Command name, its description, and array of arguments
export (String) var _name = null
export (String) var _desc = null
export (Array) var arguments = []

# Get the console node, and the output node
# These will be inherited by each command node so we don't
# have to define them for each command 
onready var console = get_parent().get_parent()
onready var output = get_parent().get_parent().get_node("Tabs/Output")

# This outputs the text
func output_text(text):
	output.bbcode_text += "\n" + text
	
