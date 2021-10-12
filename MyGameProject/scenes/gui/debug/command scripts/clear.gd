extends DebugCommand


func clear():
	executed = false
	if not console.reset_text == "":
		output.bbcode_text = console.reset_text
		executed = true
		return
	else:
		output.bbcode_text = "herp derp herp"
		return
