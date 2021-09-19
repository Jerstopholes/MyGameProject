extends Control

enum {
	ARG_FLOAT,
	ARG_INT,
	ARG_BOOL,
	ARG_STRING
}
const commands = [
	["clear", []],
	["commands", []],
	["speed", [ARG_FLOAT]],
	["debug", [ARG_BOOL]],
	["exit", []],
]

const command_list = [
	'[color=green]clear[/color] -- Clears the console of all text.',
	'[color=green]commands[/color] -- Lists all valid commands you can use.',
	'[color=green]debug[/color] [color=yellow]([i]on/off[/i])[/color] -- Turns debugging mode on or off.',
	'[color=green]exit[/color] -- Clears and exits the console.',
	'[color=green]speed[/color] [color=yellow](Number: [i]speed[/i])[/color] -- Sets the movement speed of the player.',

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
func _process(delta):
	
	# Toggle the console
	if Input.is_action_just_pressed("console"):
		self.visible = !self.visible
		
		# Grabs the focus of the input field
		if self.visible:
			
			# Ensure that the DebugScreen isn't in the way
			$Input.grab_focus()
			
	

	if Input.is_action_just_pressed("scroll_up_history"):
		if show_history:
			command_history_index += 1
			if command_history_index >= command_history.size():
				command_history_index = command_history.size() - 1
		else:
			command_history_index = 0

		show_history = true
		
		if command_history.size() > 0:
			$Input.grab_focus()
			$Input.text = command_history[command_history_index]
			$Input.caret_position = command_history[command_history_index].length()

	
		
			
	if Input.is_action_just_pressed("scroll_down_history"):
		if show_history:
				command_history_index -= 1
				if command_history_index <= 0:
					command_history_index = 0
		else:
			command_history_index = 0
		
		show_history = true

		if command_history.size() > 0:
			$Input.grab_focus()
			$Input.text = command_history[command_history_index]
			$Input.caret_position = command_history[command_history_index].length()
	

func execute_command(var text : String):
	# Split the entered command by spaces
	var words = text.split(" ", false)
	words = Array(words)
	
	if words.size() == 0:
		return
	
	var command_word = words.pop_front()
	for c in commands:
		if c[0] == command_word:
			if words.size() != c[1].size():
				output_text(str("[color=red]",'Failure executing "', "[color=green]" ,command_word, 
				"[/color]", '", expected ', c[1].size(), ' parameter(s).',"[/color]"))
				return
			for i in range(words.size()):
				if not check_type(words[i], c[1][i]):
					output_text(str("[color=red]", 'Failure executing "', "[color=green]", command_word,
					"[/color]", '" parameter ', (i + 1), 
					'("', words[i], '") is of the wrong type.'))
					return
			if GameManager.allow_console:
				output_text("Executing " + "[color=green][b]" + text + "[/b][/color]" )
				callv(command_word, words)
				
				# Only insert valid commands into the command history
				if words.size() > 0:
					command_history.insert(0, command_word + " " + words[0])
				else:
					command_history.insert(0, command_word)
				
				if command_history.size() > command_history_limit:
					command_history.remove(command_history.size() - 1)
			else:
				output_text(str("[b][color=red]CONSOLE COMMANDS ARE CURRENTLY DISABLED.[/color][/b]", "\n",
				"[color=yellow][i]To enable, toggle 'Allow Console Commands' in the debug menu (CTRL+D).[/i][/color]"))
			return
	# Tell the user the command doesn't exist
	output_text(str("[color=red]", '"', "[color=green]", command_word, "[/color]", '" is not a valid command!', "[/color]"))
	

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
	
	
func output_text(var text : String):
	$Output.bbcode_text += "\n" + text


func _on_Input_text_entered(new_text):
	show_history = false
	# Clears the input
	$Input.clear()

	
	# Only output when the new text isn't blank
	if not new_text == "":
		# Execute the text
		execute_command(new_text)
		
# Clear's the Output's text
func _on_Clear_pressed():
	$Output.bbcode_text = reset_text


func speed(var speed):
	print("set speed", speed)
	
func commands():
	for i in range(command_list.size()):
		output_text(command_list[i])
		
func clear():
	$Output.bbcode_text = reset_text
	
func debug(state):
	if state == "on":
		GameManager.debugmode = true
	elif state == "off":
		GameManager.debugmode = false

func exit():
	$Output.bbcode_text = reset_text
	hide()
	

	

