extends Node

class_name DebugCommand, "res://assets/icons/debugconsoleiconoutlined.png"

# Command name, its description, and array of arguments
export (String) var _name = null
export (String) var _desc = null
export (Array) var arguments = []

# Stored colors
var error = "[color=red]ERROR[/color]: "
var warning = "[color=yellow]WARNING[/color]: "

# This lets us know if the command was succesfully executed.
# When a function is called, "executed" is *always* reset to "false", 
# and then only set to "true" if the function actually does what it's supposed to.
# This is used to determine if what the user typed into the console is a valid command, 
# and if it is, ensure it executed properly before we store the command in the command history.
var executed : bool = false

# Find the console and the output node. 
onready var console = find_parent("DebugConsole")
onready var output = find_parent("DebugConsole").find_node("Output")

# This outputs the text to the console
func output_text(text):
	output.append_bbcode(str("\n", text))
