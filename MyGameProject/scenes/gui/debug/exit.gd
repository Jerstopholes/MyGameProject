extends DebugCommand

func exit():
	executed = false
	console.hide()
	debug_log("Exited the console successfully.")
	executed = true
