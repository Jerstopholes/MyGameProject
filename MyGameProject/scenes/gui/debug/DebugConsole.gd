extends Control


onready var tab = $Tabs
onready var input = $Input
onready var output = $Tabs/Output
onready var commands = $Commands

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Ensure we are hidden by default
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("console"):
		input.clear()
		self.visible = !self.visible
		
		if visible:
			input.grab_focus()

# Execute the command
func execute(command, args):
	# Iterate over the commands. If one matches, call it!
	for c in range (commands.get_child_count()):
		if command == commands.get_child(c).name:
			var exec = commands.get_child(c)
			# The command matches, but do the arguments match?
			if args.size() != exec.arguments.size():
				output.bbcode_text += str("\n[color=red]ERROR[/color]:",
				' Command "', command, '" expected ', exec.arguments.size(), ' arguments, ',
				'received ', args.size(), '.')
				return
			exec.callv(exec.name, args)
			if GameManager.debugmode:
				output.bbcode_text += str('\n[[color=fuchsia]debug log[/color]] Command "', command,
				'" executed!')

func _on_Input_text_entered(new_text):
	
	# Only send text if the input field isn't empty
	if not new_text == "":
		
		# Convert it all to lower case
		new_text.to_lower()
		# Get the command word and then the parameter
		var split = new_text.split(" ", false)
		split = Array(split)
		
		# The command word is the first word off of the split array
		var command = split.pop_front()
		
		# Everything else is arguments
		var args = split
		
		# Attempt to execute the command
		execute(command, args)
		
		# Clear the input field
		input.clear()

