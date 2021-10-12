extends DebugCommand


func setspeed(args):
	executed = false
	if args.is_valid_float():
		GameManager.player.move_speed = args
		output_text("Set the player speed to " + str(args))
		executed = true
	else:
		output_text(str(error, 'the supplied argument "', args, '" is not correct! I need a number from 0.0 to 20.0!'))
