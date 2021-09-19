extends Node

enum {
	ARG_FLOAT,
	ARG_INT,
	ARG_BOOL,
	ARG_STRING
}
const commands = [
	["commands",[]],
	["set_speed",[ARG_FLOAT]]
]

const command_list = [
	"commands",
	"set_speed",
	"debugmode",
]

func set_speed(var speed):
	print("set speed")
	
func commands():
	get_parent().output_text(str(command_list))
	pass
