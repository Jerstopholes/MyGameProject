extends Node

# These variables store important data.
var player = PlayerData.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Simply testing the player data class
	player.init_player("Harold Dolrah")
	player.statistics()


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
	
	#TODO: Save the player object in a new game file
	
# Saves the current game progress
func save_game(var game : String):
	pass
	
# Loads a game into memory
func load_game(var game : String):
	pass
