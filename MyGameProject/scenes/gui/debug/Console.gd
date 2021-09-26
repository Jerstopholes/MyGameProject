extends Control

enum {
	ARG_FLOAT,
	ARG_INT,
	ARG_BOOL,
	ARG_STRING,
}

# Array holding valid commands and their arguments
const commands = [
	["clear", []],
	["ls", [ARG_STRING]],
	["set", [ARG_STRING, ARG_STRING]],
	["exit", []],
	["help", [ARG_STRING]],
]


# Array that holds valid function names
const functions = [
	"speed",
	"debugmode",
	"godmode",
	"jumpheight",
	"unlockall",
	"devops",
]

# Array holding parameters
const parameters = [
	"commands",
	"functions",
]

# Array which stores information about the callable functions
const function_list = [
	'[color=teal]--- VALID FUNCTIONS LIST ---[/color]',
	str("-> [color=green]SET[/color] [color=yellow]speed[/color] ([color=aqua]number[/color])",
	" -- Sets the speed of the player with [color=aqua]number[/color]."),
	str("-> [color=green]SET[/color] [color=yellow]debugmode[/color] ([color=aqua]on/off[/color])",
	" -- Sets debugging mode to either [color=aqua]on/off[/color]."),
	str("-> [color=green]SET[/color] [color=yellow]godmode[/color] ([color=aqua]on/off[/color]) -- Used to make the player invincible."),
	str("-> [color=green]SET[/color] [color=yellow]jumpheight[/color] ([color=aqua]number[/color]) -- Used to set the player's jump height with [color=aqua]number[/color]."),
	str("-> [color=green]SET[/color] [color=yellow]unlockall[/color] ([color=aqua]on/off[/color]) -- Unlocks all player abilities."),
	str("-> [color=green]SET[/color] [color=yellow]devops[/color] ([color=aqua]on/off[/color]) -- Allows execution of [color=blue]developer level[/color] commands."),
	str("[color=teal]--- END OF LIST ---[/color]")
	
]

# Array which stores information about the commands and their arguments
const command_list = [
	'[color=teal]--- VALID COMMAND LIST ---[/color]',
	'[color=green]clear[/color] -- Clears the console of all text.',
	'[color=green]exit[/color] -- Exits the console and leaves console output intact.',
	'[color=green]ls [/color][color=aqua]<commands>[/color] OR [color=aqua]<functions>[/color] -- Lists all valid commands/functions you can use.',
	str('[color=green]set [/color]([color=yellow]func[/color], [color=aqua]param[/color])', 
	'-- Sets the [color=yellow]function[/color]', ' with the [color=aqua]parameter[/color].',
	' For valid functions, use [color=green]ls[/color] [color=aqua]functions[/color].'),
	'[color=green]help[/color] [color=aqua]<command>[/color] -- Displays helpful information for using specific commands.',
	"[color=teal]--- END OF LIST ---[/color]"
]

# Command history
var command_history = []
var command_history_index : int = 0
var command_history_limit : int = 24
var comms = []
var show_history : bool = false

var reset_text

onready var input = $Input
onready var output = $Tabs/Console
onready var debug = $"Tabs/Debug Info"
# Called when the node enters the scene tree for the first time.
func _ready():
	# Store the reset text for the console
	reset_text = output.bbcode_text
	
	# Fill up the comms array
	for c in commands:
		comms.append(c[0])
	
	# Hide the console on startup
	self.visible = false
	
func _process(delta):
	# Toggle the console
	if Input.is_action_just_pressed("console"):
		self.visible = !self.visible
		# Don't catch the tilde!
		input.text = ""
		
	# Allow the display of debug information when enabled
	if GameManager.debugmode:
		tabs.set_tab_disabled(1, false)
		tabs.set_tab_title(1, "Debug")
	else:
		$Tabs.set_tab_disabled(1, true)
		$Tabs.set_tab_title(1, "")
		
	# Display debugging information only when the debug tab is selected
	if $Tabs.current_tab == 1:
		input.hide()
		$CopyButtonPanel.show()
		debug.bbcode_text = str("\n[color=aqua]Frames/sec[/color]: ", Engine.get_frames_per_second(),
		"\n[color=aqua]Memory usage[/color]: ", OS.get_static_memory_usage(),
		"\n[color=aqua]Video Backend[/color]: ", OS.get_video_driver_name(OS.get_current_video_driver()),
		"\n[color=aqua]VSync[/color]: ", OS.is_vsync_enabled(),
		"\n[color=aqua]Data Location[/color]: ", OS.get_user_data_dir())
	elif $Tabs.current_tab == 0:
		debug.bbcode_text = "If you see this message, I broke something."
		$CopyButtonPanel.hide()
		input.show()
		input.grab_focus()
		
		if input.has_focus():
			if Input.is_action_just_pressed("scroll_up_history"):
				if show_history:
					command_history_index += 1
				else:
					command_history_index = 0
				if command_history_index >= command_history.size():
					command_history_index = command_history.size() -1
				show_history = true
				
				if command_history.size() > 0 and show_history:
					input.text = command_history[command_history_index]
					input.caret_position = command_history[command_history_index].length()

			if Input.is_action_just_pressed("scroll_down_history"):
				if show_history:
					command_history_index -= 1
				else:
					command_history_index = 0
				if command_history_index <= 0:
					command_history_index = 0
				show_history = true

				if command_history.size() > 0 and show_history:
					input.text = command_history[command_history_index]
					input.caret_position = command_history[command_history_index].length()



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
				'", expected ', c[1].size(), ' parameter(s), and received ', words.size(), "."))
				return
			
			# Incorrect parameter type was used for the command argument
			for i in range(words.size()):
				if not check_args(words[i], c[1][i]):
					output_text(str("[color=red]ERROR:[/color]", ' Failure executing "', command_word,
					'" parameter ', (i + 1), '("', words[i], '") is not the expected type.'))
					return


			# The function, parameter or command does not exist (yikes!)
			if not words.empty():
				if not check_command(words[0]) and not check_function(words[0]) and not check_parameter(words[0]):
					output_text(str('[color=red]!!!EXECUTION FAILED!!![/color]\n',
					"Execution could not be completed on [color=maroon]", command_word, " ", words[0], "[/color]",
					"\nPlease check spelling and that the [color=green]command[/color]/[color=yellow]function[/color]/[color=aqua]parameter[/color] is valid!"))
					return
	
			# We made it through all of the checks so execute the command 
			# and add it to the command history array
			callv(command_word, words)
			
			# Only insert valid commands into the command history
			if words.size() > 0:
				# Store the contents of the command
				var contents = ""
				for w in range(words.size()):
					
					# Adds a space between function name and parameter
					if w != words.size() - 1:
						contents += words[w] + " "
					else:
						contents += words[w]
				
				# Loop through and make sure we don't keep anymore "dots" than necessary
				# (Specifically used in float arguments).
				var trimmed = ""
				var dot_counter = 0
				
				for i in range(contents.length()):
					if contents[i] == ".":
						# Strike!
						dot_counter += 1
					
					# Only store the contents if we haven't found two dots
					if dot_counter < 2:
						trimmed += contents[i]
				
				# Now we can add the command to the command history
				command_history.insert(0, command_word + " " + trimmed)
			else:
				# No parameters, so only store the command word
				command_history.insert(0, command_word)
			
			# Remove elements from the command history when we reach the limit
			if command_history.size() > command_history_limit:
				command_history.remove(command_history.size() - 1)
			
			# Inform the user the command was executed succesfully while debugmode is on
			if GameManager.debugmode:
				output_text(str('[[color=fuchsia]debug log[/color]]--> [color=lime]', command_history[0], '[/color] executed succesfully!'))
			return
		
	# Tell the user the command doesn't exist
	output_text(str("[color=red]ERROR: [/color]", '"', command_word, '" does not exist!'))
	

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
	output.bbcode_text = reset_text
	
# Exits the console
func exit():
	hide()

# -- set(function, parameter) function
# -- Used to set a particular function with parameter.
func set(function, parameter):
	if function == "debugmode": # Set the debug mode on or off
		if parameter == "on":
			GameManager.debugmode = true
			output_text('[color=teal]Set debugmode to ON.[/color]')
		else:
			GameManager.debugmode = false
			output_text('[color=teal]Set debugmode to OFF.[/color]')
	
	if function == "speed": # Set the speed of the player
		output_text(str('[color=teal]Set Player Speed to ', float(parameter), ".[/color]"))
	
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
		output_text(str("-- [color=green]set[/color] [color=yellow]<function>[/color] [color=aqua]<parameter>[/color] --\n",
		'[color=green]Set[/color] needs two parameters - the [color=yellow]function[/color] ',
		"to call, and the [color=aqua]parameter[/color] for the [color=yellow]function[/color].",
		'\nFor Example, [color=green]Set[/color] [color=yellow]Speed[/color] [color=aqua]2.45[/color] will set the player speed to 2.45.'))
	if function == "ls":
		output_text(str("-- [color=green]ls[/color][color=aqua] <commands> <functions> [/color]-- \n",
		"Requires [color=aqua]commands[/color] or [color=aqua]functions[/color] as the parameter, ",
		"and lists all valid commands/functions. \nFor example, type [color=green]ls[/color] [color=aqua]functions[/color]."))
	if function == "clear":
		output_text(str("[color=silver]-- Help for[/color] [color=green]clear[/color] [color=silver]--[/color] \n",
		"Clears the console."))
	if function == "exit":
		output_text(str("[color=silver]-- Help for[/color] [color=green]exit[/color][color=silver] --[/color] \n",
		"Exits the console.  Does not clear console of text and keeps command history."))
	if function == "help":
		output_text("The answer to Life, the Universe, and Everything = [color=aqua]42[/color].")

# Checks the parameter type supplied with the command and ensures it's valid.
func check_args(string, type):
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
	# Search for the command and check that it actually exists
	if comms.find(string, 0) == -1:
		# Nothing was found
		return false
	else:
		# A match was found
		return true
		
func check_parameter(string):
	if parameters.find(string, 0) == -1:
		return false
	else:
		return true

# Output text to console with formatting
func output_text(var text : String):
	output.append_bbcode("\n" + text)
	
# When the user enters text
func _on_Input_text_entered(new_text):
	test(new_text)
	# Stop showing history, if we are in fact showing it
	show_history = false
	# Clears the input
	input.clear()
	# Only output text when the new text isn't blank
	if not new_text == "":
		# Execute the text but first convert it to all lowercase
		var text = new_text.to_lower()
		execute_command(text)

func test(var args):
	var text = args.split(" ", false)
	text = Array(text)
	print(text)
	print(text.size())

func _on_CopyToClipboard_pressed():
	# Copy the contents of debug info to the user's clipboard
	OS.set_clipboard(debug.text)
	output_text("[color=yellow]Succesfully copied debug info to clipboard![/color]")
	pass # Replace with function body.
