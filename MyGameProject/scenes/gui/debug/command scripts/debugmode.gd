extends DebugCommand


func debugmode(arg):
	executed = false
	if arg == "on":
		if GameManager.debugmode:
			output_text(str(warning, "Debug Mode is already turned on!"))
			return
		else:
			GameManager.debugmode = true
			executed = true
			output_text("Debug Mode is ON.")
			return
	if arg == "off":
		if not GameManager.debugmode:
			output_text(str(warning, "Debug Mode is already turned off!"))
			return
		else:
			GameManager.debugmode = false
			executed = true
			output_text("Debug Mode is OFF.")
			return 
	else:
		output_text(str(error, 'Parameter mismatch: "', arg, 
		'" is not valid! Use "on" or "off".'))
		return
		
