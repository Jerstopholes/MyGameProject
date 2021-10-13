extends Control

export (int) var history_limit = 20


onready var input = $Input
onready var output = $Output

var error = "\n[color=red]ERROR[/color]: "
var reset_text : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Store the reset text
	reset_text = output.bbcode_text
	
	# Ensure the console is hidden by default
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	GameManager.console_active = visible

	# If we toggled the console
	if Input.is_action_just_pressed("console"):
		# Clear the input as we don't want to actually cache the key press
		input.clear()
		
		# Flip the value of visible
		visible = !visible
		
		if visible:
			input.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Update the debug panel
	var fps = Engine.get_frames_per_second()
	var phys_fps = Engine.iterations_per_second
	var win_size = Vector2(OS.get_window_size().x, OS.get_window_size().y)

	var fullscreen = OS.is_window_fullscreen()
	var vsync = OS.is_vsync_enabled()
	var memory_usage_mb = stepify(Performance.get_monitor(Performance.MEMORY_STATIC) / (1024*1024), 0.001)
	var memory_usage_gb = stepify(Performance.get_monitor(Performance.MEMORY_STATIC) / (1024*1024*1024), 0.0001)
	
	$Tabs/Performance.bbcode_text = str("[color=purple]FPS[/color]: ", fps,
			"\n[color=purple]Physics Steps[/color]: ", "Set to ", phys_fps,
			"\n[color=purple]Process Time[/color]: ", 
			Performance.get_monitor(Performance.TIME_PROCESS)," ms",
			"\n[color=purple]Phyics Process Time[/color]: ", 
			Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS), " ms",
			"\n[color=purple]Process ID[/color]: ", OS.get_process_id(),
			"\n[color=purple]Current RAM Usage[/color]: ", memory_usage_mb," MB (", memory_usage_gb, " GB)")
			
	$Tabs/Rendering.bbcode_text = str("[color=purple]Window Size[/color]: ",
			win_size.x, "x", win_size.y,
			"\n[color=purple]Base Resolution[/color]: ", IntegerResolutionHandler.base_resolution.x,
			"x", IntegerResolutionHandler.base_resolution.y,
			"\n[color=purple]Fullscreen Enabled[/color]: ", fullscreen, 
			"\n[color=purple]VSync Enabled[/color]: ", vsync,
			"\n[color=purple]Objects in Scene[/color]: ",
			Performance.get_monitor(Performance.OBJECT_COUNT)
			)
	
	# Control focus modes 
	if $History.has_focus():
		output.focus_mode = Control.FOCUS_CLICK
		input.focus_mode = Control.FOCUS_CLICK
	


# Execute the command
func execute(command, args):
	var valid_command = false
	var exec : Node
	
	# Iterate over the commands. If one matches, call it!
	for c in get_child_count():
		# We only care about the nodes that are of type DebugCommand
		if get_child(c) is DebugCommand:
			if command == get_child(c).name:
				exec = get_child(c)
				
				# The command matches, but do the arguments match?
				if args.size() != exec.arguments.size():
					output.append_bbcode(str(error,
					'Command "', command, '" expected ', exec.arguments.size(), ' arguments, ',
					'received ', args.size(), ' instead.'))
					return
				
				valid_command = true
				break
				
	if valid_command:
		# Call the command
		exec.callv(exec.name, args)
		
		# Before we add the command to the history we have to ensure the command
		# *actually* executed properly.
		if exec.executed:
			# The command matched and it's valid!
			valid_command = true
			
			print("COMMAND EXECUTED!")
			# Prepare to store the command in the history array.
			# First get the command and the arguments, converted to text.
			var text = ""
			
			# Only store the arguments if the arguments array is not empty.
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
				
			# Update the History display
			$History.add_item(store, null, true)
			
			if $History.get_item_count() >= history_limit:
				$History.remove_item(0)

		else:
			printerr("COMMAND EXECUTION FAILED.")

	# If valid_command is false, we know the command doesn't exist.
	else:
		output.append_bbcode(str(error, 'Command "', command, '" does not exist!' ))

func _on_Input_text_entered(new_text):
	
	# Only send text if the input field isn't empty
	if not new_text == "":
		
		# Convert all the text to lower case
		var text = new_text.to_lower()
		
		# Get the command word and then the parameters by chopping out spaces. 
		# This will then be converted into an array for processing.
		var contents = text.split(" ", false)
		contents = Array(contents)
		
		# The command word is the first word off of the contents array,
		# so pop it off and remove it from the array.
		var command = contents.pop_front()
		
		# Execute the command, with "contents" being the argument array
		execute(command, contents)
		
		# Clear the input field
		input.clear()

# If we activate the selected item, re-execute the command.
func _on_History_item_activated(index):
	input.emit_signal("text_entered", $History.get_item_text(index))

# Automatically select the first item upon focus.
func _on_History_focus_entered():
	if $History.get_item_count() > 0:
		$History.select(0, true)
		input.text = $History.get_item_text(0)
		input.caret_position = $History.get_item_text(0).length()

# Set the input's text to the selected text.
func _on_History_item_selected(index):
	input.text = $History.get_item_text(index)
	input.caret_position = $History.get_item_text(index).length()

# Unselect anything that's selected when losing focus.
func _on_History_focus_exited():
	$History.unselect_all()


func _on_monitor_pressed():
	var name = OS.get_name()
	
	if name == "Windows":
		OS.shell_open("resmon")
	else:
		print("what")

func _on_savefolder_pressed():
	OS.shell_open(OS.get_user_data_dir()+"/saves")
	output.append_bbcode(str("\nOpened the save folder!"))
	

func _on_exitconsole_pressed():
	hide()

func _on_clearhistory_pressed():
	$History.items = []
	output.append_bbcode(str("\nCleared the Command History!"))
