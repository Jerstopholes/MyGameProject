extends DebugCommand


func clear():
	executed = false
	output.bbcode_text = ""
	debug_log("Console Cleared!")
	executed = true


