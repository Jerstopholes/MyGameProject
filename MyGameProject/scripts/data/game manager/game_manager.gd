extends Node

# The default instance of the player. 
var player = PlayerData.new()

var path = "user://saves/"
var ext = ".jwg" # In Doc Brown's voice: "MY INITIALS!"


# Called when the node enters the scene tree for the first time.
func _ready():
	start_new_game("Xander", "xanderini")

# When called, this starts a new game
func start_new_game(var player_name : String, var save_name : String):
	# Initialize the player with starting values
	player.level_player_is_in = ""
	player.save_file_name = save_name
	player.player_name = player_name
	player.current_health = 100.0
	player.max_health = 100.0
	player.max_health_multiplier = 1.0
	player.current_astral_energy = 50.0
	player.max_astral_energy = 50.0
	player.max_astral_energy_multiplier = 1.0
	player.total_secrets_found = 0
	player.total_inhabited_people = 0
	player.total_inhabited_objects = 0
	player.is_save_file_used = true
	
	
	# Save the game
	save_game("ThisFileIsValid", player)
	load_game("NowLoadOneThatDoesNotExist")
	
# Saves the current game progress
func save_game(var game : String, var data : PlayerData):
	# Create a save directory instance
	var folder = Directory.new()
	folder.make_dir_recursive(path)
	
	# Create a file instance and open it for writing. 
	var f = File.new()
	f.open(path+game+ext, File.WRITE)
	
	# Mark this file as in-use
	data.is_save_file_used = true
	
	# Now store the data to disk and close the file
	f.store_line(to_json(inst2dict(data)))
	f.close()
	print('Succesfully saved "'+game+ext+'" to disk!')

# Loads a game into memory
func load_game(var game : String):
	# Load the data straight into player
	player = open_if_exists(game)
	
	if player:
		player.get_statistics(player)
	else:
		printerr("Error loading the game, the selected file doesn't exist.")
		return
	
# Checks if a file is in use
func is_file_in_use(var game : String):
	var data = open_if_exists(game)
	if data:
		return data.is_save_file_used
		
# Returns the name of the file from within the file
func get_file_name(var game : String):
	var data = open_if_exists(game)
	if data:
		return data.save_file_name
		
# Opens the file if it exists, and if it doesn't, returns an error.
func open_if_exists(var game : String):
	var f = File.new()
	var data = PlayerData.new()
	if f.file_exists(path+game+ext):
		f.open(path+game+ext, File.READ)
		data = dict2inst(parse_json(f.get_line()))
		f.close()
		
		return data
	else:
		printerr('CRITICAL ERROR: File ' + '"'+game+ext+'" was not found!')
		return

