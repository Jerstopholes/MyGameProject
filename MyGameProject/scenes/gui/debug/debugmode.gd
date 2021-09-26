extends DebugCommand


func debugmode(arg):
	executed = false
	if arg == "on":
		GameManager.debugmode = true
		debug_log("Debug Mode is now on")
		executed = true
		return
	if arg == "off":
		debug_log("Debug Mode is now off")
		GameManager.debugmode = false
		executed = true
		return 
	else:
		output_text(str(error, 'Could not execute "debugmode"!\n', 
		'Parameter "', arg, '" is not valid! Use either "on" or "off".'))
		return
		
