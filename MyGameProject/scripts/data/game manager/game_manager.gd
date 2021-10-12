extends Node

# The default instance of the player. 
var player : PlayerData = PlayerData.new()

# The save path and file extension (put here so that they can be changed easily if needed)
var path : String = "user://saves/"
var ext : String = ".jwg" # In Doc Brown's voice: "MY INITIALS!"

# This is used to track whether or not we should allow the console to be brought up
var debugmode : bool = true
var request_quit : bool = false
var console_active : bool = false

# This is used to count the game play time
var calculate_time : bool = true

var hours : int = 0
var mins : int = 0
var secs : float = 0.0
var hours_mins : String = ""
var total_time : String = ""

var play_time = {}

# The currently selected game file
var current_game_file : String = "sample"


# This enum helps us determine properties of a game file
enum property {NAME, USED}

# Called when the node enters the scene tree for the first time.
func _ready():
	start_new_game(current_game_file)
	set_process(true)
	
# Calculates time elapsed and nothing else
func _process(delta):
	# Calculate the elapsed time
	# Store the playtime for the player separately, but use this as the base
	if round(secs) == 60:
		mins += 1
		player.total_play_time.mins += 1
		print(str("Uptime: ", player.total_play_time))
		
		secs = 0
	else:
		secs += delta
		
	if mins == 60:
		hours += 1
		player.total_play_time.hours += 1
		mins = 0
	
	total_time = str("Hours: ", hours, " Mins: ", mins, " Secs: ", round(secs))
	hours_mins = str("Hours: ", hours, " Mins: ", mins)
	
	# Store the playtime in a dictionary for easy lookup
	play_time = {
		"hours" : hours,
		"mins" : mins,
		"secs" : round(secs),
		"hours_mins" : hours_mins,
		"total_time" : total_time
	}
	

# When called, this starts a new game
func start_new_game(var player_name : String):
	# TODO: Make sure the file isn't being used first!
	# TODO: Write handling code here (check if the player wants to reset the file)
	
	# Initialize the player with starting values
	player.initialize(player_name)
	
	# Save the game
	save_game(current_game_file, player)

	# TODO: Game launch code here (start loading first level)
	
# Saves the current game progress
func save_game(var game : String, var data : PlayerData):
	var new_path = path+game+"/"
	# Create a save directory instance
	var folder = Directory.new()
	folder.make_dir_recursive(new_path)
	
	# Create a file instance and open it for writing. 
	var f = File.new()
	f.open(new_path + game + ext, File.WRITE)
	
	# Mark this file as in-use
	data.is_save_file_used = true
	
	# Now store the data to disk and close the file
	f.store_line(to_json(inst2dict(data)))
	f.close()
	print('Succesfully saved "' + game + ext +'" to disk!')

# Loads a game into memory
func load_game(var game : String):
	# Load the data straight into player
	player = open_if_exists(game)
	
	if player:
		player.get_statistics(player)
		print("Loaded the game succesfully!")
	else:
		printerr('Cannot load file "' + game + ext + '" as it does not exist!')
		return
	
# Get a particular property from a file
func get_file_property(var game : String, var p):
	var data = open_if_exists(game)
	if data:
		match(p):
			property.NAME:
				return data.save_file_name
			property.USED:
				return data.is_save_file_used
			_:
				printerr('"' + p + '" is not a valid property of "' + game + ext + '"! Expected "NAME" or "USED".')
				return
		
# Opens the file if it exists, and if it doesn't, returns an error.
func open_if_exists(var game : String):
	var new_path = path + game + "/" + game + ext
	var f = File.new()
	if f.file_exists(new_path):
		f.open(new_path, File.READ)
		var data = dict2inst(parse_json(f.get_line()))
		f.close()
		
		return data
	else:
		printerr('CRITICAL ERROR: File ' + '"' + game + ext +'" was not found!')
		return

