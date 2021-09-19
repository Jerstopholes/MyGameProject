class_name PlayerData

# These store the player's health and astral energy levels
var current_health : float
var max_health : float
var max_health_multiplier : float
var current_astral_energy : float
var max_astral_energy : float
var max_astral_energy_multiplier : float

# This stores the player's name, level information and save file name
var player_name : String
var level_player_is_in : String
var save_file_name : String

# These variables track how many secrets the player has found and
# how many objects or beings they have inhabited
var total_secrets_found : int
var total_inhabited_people : int
var total_inhabited_objects : int

# This lets us know if the save file is writeable
var is_save_file_used : bool

# Initializes a player object
func initialize(var game : String):
	# Initialize the player with starting values
	level_player_is_in = ""
	save_file_name = game
	player_name = player_name
	current_health = 100.0
	max_health = 100.0
	max_health_multiplier = 1.0
	current_astral_energy = 50.0
	max_astral_energy = 50.0
	max_astral_energy_multiplier = 1.0
	total_secrets_found = 0
	total_inhabited_people = 0
	total_inhabited_objects = 0
	is_save_file_used = true


# Returns all of the player's current statistics
func get_statistics(var data : PlayerData):
	print("The data of Player " + data.player_name +":\n", inst2dict(data))
