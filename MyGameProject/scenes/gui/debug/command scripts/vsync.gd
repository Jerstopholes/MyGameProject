extends DebugCommand


func vsync(args):
	executed = false
	if args == "on":
		OS.vsync_enabled = true
		output_text("VSync is ON.")
		executed = true
		return
	elif args == "off":
		OS.vsync_enabled = false
		output_text("VSync is OFF.")
		executed = true
		return
	else:
		output_text(str(error, 'Parameter mismatch, "', args, '" is not valid. Use "on" or "off".'))
		return
