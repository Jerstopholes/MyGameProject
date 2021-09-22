extends Control

enum {
	ARG_FLOAT,
	ARG_INT,
	ARG_BOOL,
	ARG_STRING,
}

# Array that holds valid function names
const functions = [
	"speed",
	"debugmode",
	"commands",
	"functions",
	"godmode",
	"jumpheight",
	"unlockall",
	"devops",
]

# Array which stores information about the callable functions
const function_list = [
	'--- VALID FUNCTIONS ---',
	'USE [color=green]SET[/color] WITH...',
	str(">	 [color=green]speed (arg: number)[/color]",
	" -- Sets the speed of the player with [color=yellow]number[/color]."),
	str(">	 [color=green]debugmode (arg: on/off)[/color]",
	" -- Sets debugging mode to either [color=yellow]on[/color]/[color=yellow]off[/color]"),
	str(">	 [color=green]godmode (arg: on/off)[/color] -- Used to make the player invincible."),
	str(">	 [color=green]jumpheight (arg: number)[/color] -- Used to set the player's jump height with [color=yellow]number[/color]."),
	str(">	 [color=green]unlockall (arg: on/off)[/color] -- Unlocks all player abilities."),
	str(">	 [color=green]devops (arg: on/off)[/color] -- Allows execution of developer level commands."),
	
]
# Array holding valid commands and their arguments
const commands = [
	["clear", []],
	["ls", [ARG_STRING]],
	["set", [ARG_STRING, ARG_STRING]],
	["exit", []],
	["help", [ARG_STRING]],
]

# Array which stores information about the commands and their arguments
const command_list = [
	'--- VALID COMMANDS ---',
	'[color=green]clear[/color] -- Clears the console of all text.',
	'[color=green]exit[/color] -- Clears and exits the console.',
	'[color=green]ls <commands> OR <functions>[/color] -- Lists all valid commands/functions you can use.',
	str('[color=green]set (arg: func, arg: param)[/color] -- Sets the function with the parameter.',
	' For valid functions, use [color=green]ls functions[/color].'),
	'[color=green]help <command name>[/color] -- Displays helpful information for using specific commands.'
]

# Command history
var command_history = []
var command_history_index : int = 0
var command_history_limit : int = 24
var comms = []
var show_history : bool = false

var reset_text

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_text = $Panel/Output.bbcode_text
	hide()
	
func _process(delta):
	# Toggle the console
	if Input.is_action_just_released("console"):
		self.visible = !self.visible
		# Don't catch the tilde!
		$Input.text = ""
		
		# Grabs the focus of the input field
		if self.visible:
			# Ensure that the DebugScreen isn't in the way
			$Input.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if $Input.has_focus():
		if Input.is_action_just_pressed("scroll_up_history"):
			if show_history:
				command_history_index += 1
			else:
				command_history_index = 0
			if command_history_index >= command_history.size():
				command_history_index = command_history.size() -1
			
			if command_history.size() > 0:
				$Input.text = command_history[command_history_index]
				$Input.caret_position = command_history[command_history_index].length()
				show_history = true
		
		if Input.is_action_just_pressed("scroll_down_history"):
			if show_history:
				command_history_index -= 1
			else:
				command_history_index = 0
			if command_history_index <= 0:
				command_history_index = 0
				
			if command_history.size() > 0:
				$Input.text = command_history[command_history_index]
				$Input.caret_position = command_history[command_history_index].length()
				show_history = true


func execute_command(var text : String):
	# Split the entered command by spaces
	var words = text.split(" ", false)
	words = Array(words)
	
	if words.size() == 0:
		return
	
	var command_word = words.pop_front()
	
	for c in commands:
		if (c[0] == command_word):
			# Not enough parameters
			if words.size() != c[1].size():
				output_text(str("[color=red]ERROR:[/color]",' Failure executing "', command_word, 
				'", expected ', c[1].size(), ' parameter(s).'))
				return
			for i in range(words.size()):
				# Incorrect parameter was used
				if not check_type(words[i], c[1][i]):
					output_text(str("[color=red]ERROR:[/color]", ' Failure executing "', command_word,
					'" parameter ', (i + 1), '("', words[i], '") is of the wrong type.'))
					return
					
				# The function does not exist
				if not command_word == "help":
					if not check_function(words[0]):
						output_text(str('[color=red]ERROR:[/color] Failure executing "',
						command_word,'", function "', words[0], '" does not exist!'))
						return
				else:
					if not check_command(words[0]):
						output_text(str('[color=red]ERROR:[/color] Cannot return help on "', words[0],
						'", it does not exist!'))
						return
						
			# We made it through all of the checks so execute the command 
			# and add it to the command history array
			callv(command_word, words)
			
			# Only insert valid commands into the command history
			if words.size() > 0:
				# Store the parameters of the command
				var parameter = ""
				for w in range(words.size()):
					if w != words.size() - 1:
						parameter += words[w] + " "
					else:
						parameter += words[w]
					
				command_history.insert(0, command_word + " " + parameter)
			else:
				# No parameters, so only store the command word
				command_history.insert(0, command_word)
			
			# Remove elements from the command history when we reach the limit
			if command_history.size() > command_history_limit:
				command_history.remove(command_history.size() - 1)
			
			return
		
	# Tell the user the command doesn't exist
	output_text(str("[color=red]ERROR: [/color]", '"', command_word, '" is not a valid command!'))
	

# -- ls(parameter) 
# Used to list either commands or functions.
func ls(parameter):
	if parameter == "commands":
		for i in range(command_list.size()):
			output_text(command_list[i])
	elif parameter == "functions":
		for i in range(function_list.size()):
			output_text(function_list[i])
		
# Clears the console
func clear():
	$Panel/Output.bbcode_text = reset_text
	
# Clears and exits the console
func exit():
	$Panel/Output.bbcode_text = reset_text
	hide()

# -- set(function, parameter) function
# -- Used to set a particular function with parameter.
func set(function, parameter):
	if function == "debugmode": # Set the debug mode on or off
		if parameter == "on":
			GameManager.debugmode = true
			output_text('[color=yellow]Set debugmode to ON.[/color]')
		else:
			GameManager.debugmode = false
			output_text('[color=yellow]Set debugmode to OFF.[/color]')
	
	if function == "speed": # Set the speed of the player
		output_text(str('[color=yellow]Set Player Speed to ', float(parameter), ".[/color]"))
	
	if function == "godmode": # Sets godmode on or off, making the player invincible
		print("TODO: add godmode")
	
	if function == "jumpheight": # Sets the jumpheight of the player
		print("TODO: add jumpheight")
	
	if function == "unlockall": # Allows all player abilities to be unlocked no matter what
		print("TODO: add code to unlock all player abilities")
		
	if function == "devops": # Allows the execution of developer level commands
		print("TODO: add developer level commands")
	
# -- help(function)
# Used to get help with a particular command or function
func help(function):
	if function == "set":
		output_text(str("[color=green]set[/color] -- Expects one (1) function, i.e,"))
		output_text(str("[color=green]speed (arg: number speed)[/color]",
		" -- Sets the speed of the player."))
		output_text(str("[color=green]debugmode (arg: bool on/off)[/color]", 
		" -- Turns debugging [color=yellow]on/off[/color]."))
	if function == "ls":
		output_text(str("[color=green]ls[/color] -- Expects [color=yellow]commands[/color] or [color=yellow]functions[/color] as input, ",
		"and lists all valid commands/functions. "))
	if function == "clear":
		output_text(str("[color=green]clear[/color] -- Clears the console."))
	if function == "exit":
		output_text(str('[color=green]exit[/color] -- Clears and exits the console.'))
	if function == "help":
		output_text("very cute ;P")

# Checks the parameter type supplied with the command and ensures it's valid.
func check_type(string, type):
	if type == ARG_BOOL:
		return (string == "on" or string == "off")
		
	if type == ARG_STRING:
		return true
		
	if type == ARG_FLOAT:
		return string.is_valid_float()
	
	if type == ARG_INT:
		return string.is_valid_integer()
		
	return false

func check_function(string):
	# Search for the function and check that it exists
	if functions.find(string, 0) == -1:
		return false
	else:
		return true

# Used with "help" command to ensure that the qualifier is indeed a command
func check_command(string):
	# First we need to get the first value of the commands array and store it in separate
	# comms array for comparison. We don't care about the parameters at the moment.
	# Only do this if the comms array is empty, so that we don't have to do it every time.
	if comms.empty():
		for c in commands:
			comms.append(c[0])

	# Search for the command and check that it actually exists
	if comms.find(string, 0) == -1:
		# Nothing was found
		return false
	else:
		# A match was found
		return true

# Output text to console with formatting
func output_text(var text : String):
	$Panel/Output.bbcode_text += "\n" + text

# When the user enters text
func _on_Input_text_entered(new_text):
	# Stop showing history, if we are in fact showing it
	show_history = false
	# Clears the input
	$Input.clear()

	# Only output when the new text isn't blank
	if not new_text == "":
		# Execute the text but first convert it to all lowercase
		var text = new_text.to_lower()
		execute_command(text)

