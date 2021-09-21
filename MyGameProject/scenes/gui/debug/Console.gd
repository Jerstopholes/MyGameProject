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
]

# Array which stores information about the callable functions
const function_list = [
	'--- VALID FUNCTIONS ---',
	str("[color=green]speed (arg: [i]number[/i])[/color]",
	" -- Use [color=green]set speed [i]1[/i][/color] to set the speed of the player to 1."),
	str("[color=green]debugmode (arg: [i]on/off[/i])[/color]",
	" -- Use [color=green]set debugmode [i]on/off[/i][/color] to turn debugging on or off."),
	str("[color=green]godmode (arg: [i]on/off[/i])[/color] -- Used to make the player invincible."),
	str("[color=green]jumpheight (arg: [i]number[/i])[/color] -- Used to set the player's jump height."),
	str("[color=green]unlockall (arg: [i]on/off[/i])[/color] -- Unlocks all player abilities."),
	
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
	str('[color=green]set (arg: [i]func[/i], arg: [i]param[/i])[/color] -- Sets the function with the parameter.',
	' For valid functions, use [color=green]ls functions[/color].'),
]

# Command history
var command_history = []
var command_history_index : int = 0
var command_history_limit : int = 24
var show_history : bool = false

var reset_text

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_text = $Output.bbcode_text
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	
	# Toggle the console
	if Input.is_action_just_released("console"):
		self.visible = !self.visible
		# Don't catch the tilde!
		$Input.text = ""
		
		# Grabs the focus of the input field
		if self.visible:
			# Ensure that the DebugScreen isn't in the way
			$Input.grab_focus()


	if Input.is_action_just_pressed("scroll_up_history"):
		if show_history:
			command_history_index += 1
		else:
			command_history_index = 0
		if command_history_index >= command_history.size():
			command_history_index = command_history.size() -1
		
		if command_history.size() > 0:
			$Input.text = command_history[command_history_index]
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
				output_text(str("[color=red]ERROR: [/color]",'Failure executing "', command_word, 
				'", expected ', c[1].size(), ' parameter(s).'))
				return
			for i in range(words.size()):
				# Incorrect parameter was used
				if not check_type(words[i], c[1][i]):
					output_text(str("[color=red]ERROR: [/color]", 'Failure executing "', command_word,
					'" parameter ', (i + 1), '("', words[i], '") is of the wrong type.'))
					return
					
				# The function does not exist
				if not command_word == "help":
					if not check_function(words[0]):
						output_text(str('[color=red]ERROR:[/color] Failure executing "',
						command_word,', function "', words[0], '" does not exist!'))
						return
				else:
					if not check_command(words[0]):
						output_text(str('[color=red]ERROR:[/color] Cannot return help on command "', words[0],
						'", it does not exist!'))
						return


			if GameManager.allow_console:
				# We made it through all of the checks, and console commands are allowed
				# so execute the command and add it to the command history array
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
				
				# Output the command history when debugging is on
				if GameManager.debugmode:
					output_text(str("[b][color=yellow][debug msg][/color]Command History:[/b] ",
					str(command_history)))
			return
	# Tell the user the command doesn't exist
	output_text(str("[color=red]", '"', command_word, '" is not a valid command!', "[/color]"))
	

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

# Used with "help"
func check_command(string):
	# First we need to get the first value of the commands array and store it in separate
	# comms array for comparison
	var comms = []
	
	# Loop through commands and add ONLY the command name (not parameters) to comms array
	for c in commands:
		comms.append(c[0])

	# Search for the command and check that it actually exists
	if comms.find(string, 0) == -1:
		# Nothing was found
		return false
	else:
		# A match was found
		return true
		
func output_text(var text : String):
	$Output.bbcode_text += "\n" + text


func _on_Input_text_entered(new_text):
	show_history = false
	# Clears the input
	$Input.clear()

	# Only output when the new text isn't blank
	if not new_text == "":
		# Execute the text
		var text = new_text.to_lower()
		execute_command(text)
	else:
		output_text("[color=yellow][i]What are you wanting me to execute, exactly? I'm not psychic.[/i][/color]")
		

func speed(var speed : int):
	output_text(str("Set player's speed to ", speed))

func ls(parameter):
	if parameter == "commands":
		for i in range(command_list.size()):
			output_text(command_list[i])
	elif parameter == "functions":
		for i in range(function_list.size()):
			output_text(function_list[i])
		

func clear():
	$Output.bbcode_text = reset_text
	
func debugmode(state):
	if state == "on":
		GameManager.debugmode = true
	elif state == "off":
		GameManager.debugmode = false

func exit():
	$Output.bbcode_text = reset_text
	hide()


func set(function, parameter):
	if function == "debugmode":
		debugmode(parameter)
	if function == "speed":
		speed(int(parameter))
	if function == "godmode":
		print("TODO: add godmode")
	if function == "jumpheight":
		print("TODO: add jumpheight")
	if function == "unlockall":
		print("TODO: add code to unlock all player abilities")
	
	
func help(function):
	if function == "set":
		output_text(str("[color=green][i]set[/i][/color] -- Expects one (1) function, i.e,"))
		output_text(str("[color=green][i]speed[/i] (arg: number [i]speed)[/i][/color]",
		" -- Sets the speed of the player."))
		output_text(str("[color=green][i]debugmode[/i] (arg: bool [i]on/off)[/i][/color]", 
		" -- Turns debugging [color=yellow][i]on/off[/i][/color]."))
	if function == "ls":
		output_text(str("[color=green][i]ls[/i][/color] -- Expects [i]commands[/i] or [i]functions[/i] as input, ",
		"and lists all valid commands/functions. "))
	if function == "clear":
		output_text(str("[color=green]clear[/color] -- Clears the console."))
	if function == "exit":
		output_text(str('[color=green]exit[/color] -- Clears and exits the console.'))
	if function == "help":
		output_text('very cute ;P')
		

	

