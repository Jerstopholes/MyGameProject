extends Node

class_name DebugCommand, "res://assets/icons/DebugConsoleIcon.png"

# Command name, its description, and array of arguments
export (String) var _name = null
export (String) var _desc = null
export (Array) var arguments = []

# Stored colors
var error = "[color=red]ERROR[/color]: "
var warning = "[color=yellow]WARNING[/color]: "

var executed : bool = false

onready var console = get_parent()
onready var input = get_parent().get_node("Input")
onready var output = get_parent().get_node("Tabs/Output")

# This outputs the text to the console
func output_text(text):
	output.append_bbcode("\n" + text)
	
# This is a debug_log command, which acts the same as output, but prints debug info with it
func debug_log(text):
	if GameManager.debugmode:
		output.append_bbcode("\n" + "[[color=fuchsia]debug log[/color]] -> " + text)
	
