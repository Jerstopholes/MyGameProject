extends DebugCommand


func fullscreen(var state):
	executed = false
	
	if state == "on":
		if OS.is_window_fullscreen():
			output_text(str(warning, "I'm already fullscreen!"))
			return
		else:
			OS.set_window_fullscreen(true)
			executed = true
			output_text(str("Fullscreen mode is ON."))
			return
	elif state == "off":
		if OS.is_window_fullscreen():
			OS.set_window_fullscreen(false)
			executed = true
			output_text(str("Fullscreen mode is OFF."))
			return
		else:
			output_text(str(warning, "I'm already a window!"))
			return
	else:
		output_text(str(error, 'Parameter mismatch, "', state, '" is not valid. Use "on" or "off".'))
		return
		
