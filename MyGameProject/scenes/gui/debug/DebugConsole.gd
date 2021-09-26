extends Control

export (int) var history_limit = 20
export (Texture) var console_icon
export (Texture) var info_icon

onready var tab = $Tabs
onready var input = $Input
onready var output = $Tabs/Output

var error = "\n[color=red]ERROR[/color]: "

# Array to store history of commands
var history = []
# The index of the history array
var hi : int = 0
# Determines if we should show the history or not
var show_history : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure we are hidden by default
	
	tab.set_tab_icon(0, console_icon)
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If we toggled the console
	if Input.is_action_just_pressed("console"):
		# Clear the input as we don't want to actually cache the key press
		input.clear()
		
		# Flip the value of visible
		visible = !visible
		
		if visible:
			input.grab_focus()
			
	if GameManager.debugmode:
		tab.set_tab_disabled(1, false)
		tab.set_tab_title(1, "Debug")
		tab.set_tab_icon(1, info_icon)
	else:
		tab.set_tab_disabled(1, true)
		tab.set_tab_title(1, "")
		tab.set_tab_icon(1, null)
			
	if tab.current_tab == 1:
		input.hide()
		
	
	elif tab.current_tab == 0:
		input.show()
		# If we want to show the history of the commands entered
		if Input.is_action_just_pressed("scroll_up_history"):
			if input.has_focus():
				if show_history:
					hi += 1
				else:
					hi = 0
		
				if hi >= history.size():
					hi = history.size() - 1
				show_history = true
				
				if history.size() > 0 and show_history:
					input.text = history[hi]
					input.caret_position = history[hi].length()
			
		if Input.is_action_just_pressed("scroll_down_history"):
			if input.has_focus():
				if show_history:
					hi -= 1
				else:
					hi = 0

				if hi <= 0:
					hi = 0
				show_history = true
					
				if history.size() > 0 and show_history:
					input.text = history[hi]
					input.caret_position = history[hi].length()

# Execute the command
func execute(command, args):
	var valid_command = false
	
	# Iterate over the commands. If one matches, call it!
	for c in get_child_count():
		# We only care about the nodes that are of type DebugCommand
		if get_child(c) is DebugCommand:
			if command == get_child(c).name:
				# The command matched and it's valid!
				valid_command = true
				var exec = get_child(c)
				
				# The command matches, but do the arguments match?
				if args.size() != exec.arguments.size():
					output.append_bbcode(str(error,
					'Command "', command, '" expected ', exec.arguments.size(), ' arguments, ',
					'received ', args.size(), '.'))
					return
					
				# Everything matched, so call the command.
				exec.callv(exec.name, args)
				
				# If the command executed properly, add the command to the history array.
				if exec.executed:
					print("command executed succesfully, adding to history!")
					# Prepare to store the command in the history array.
					# First get the command and the arguments, converted to text
					var text = ""
					
					# Only store the arguments if the arguments array is not empty.
					# Otherwise, only store the command name, since it didn't need arguments.
					if not args.empty():
						text = exec.name + " " + str(args)
					else:
						text = exec.name
						
					# Our storage string and dot counter
					var store = ""
					var dot_counter = 0
					
					# Now loop through the text and make sure we don't keep unnecessary characters.
					for t in text.length():
						# Ditch the brackets and extra periods
						if not text[t] == "[" and not text[t] == "]":
							# We found a dot! We can keep this one, though.
							if text[t] == ".":
								dot_counter += 1
							
							# Only add characters to the string while dot counter is less than 2.
							if dot_counter < 2:
								store += text[t]
						
					# Now store the command in the history array
					history.insert(0, store)
					
					# Check that the history array isn't above the size limit.
					# If it is, remove the oldest element.
					if history.size() >= history_limit:
						history.pop_back()
				else:
					print("command didn't execute properly, so no history addition here")

	# If valid_command is false, we know the command doesn't exist.
	if not valid_command:
		output.append_bbcode(str(error, 'Command "', command, '" does not exist!' ))

func _on_Input_text_entered(new_text):
	show_history = false
	
	# Make it so that output can have focus again
	output.focus_mode = Control.FOCUS_ALL
	
	# Only send text if the input field isn't empty
	if not new_text == "":
		
		# Convert it all to lower case
		var text = new_text.to_lower()
		
		# Get the command word and then the parameters by chopping out spaces. 
		# This will then be converted into an array for processing.
		var split = text.split(" ", false)
		split = Array(split)
		
		# The command word is the first word off of the split array,
		# so pop it off and remove it from the array.
		var command = split.pop_front()
		
		# Everything remaining in the array is now just an array of arguments.
		var args = split
		
		# Execute the command with the arguments array
		execute(command, args)
		
		# Clear the input field
		input.clear()

