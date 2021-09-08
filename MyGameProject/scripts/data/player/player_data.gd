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

# These variables track how many secrets the player has found
var total_secrets_found : int
var total_inhabited_people : int
var total_inhabited_objects : int

# This lets us know if the save file is writeable
var is_save_file_used : bool

# This dictionary houses all of the above information
var data = { 
	"health" : current_health, 
	"max_health" : max_health,
	"max_health_multiplier" : max_health_multiplier, 
	"astral_energy" : current_astral_energy,
	"max_astral_energy" : max_astral_energy,
	"max_astral_energy_multiplier" : max_astral_energy_multiplier,
	"player_name" : player_name,
	"level_player_is_in" : level_player_is_in,
	"save_file_name" : save_file_name,
	"total_secrets_found" : total_secrets_found,
	"total_inhabited_people" : total_inhabited_people,
	"total_inhabited_objects" : total_inhabited_objects,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Initializes the player object with a name
func init_player(var name : String):
	data["player_name"] = name
	pass

# Returns all of the player's current stats
func statistics():
	print("Here is the data of this player: \n", data)
