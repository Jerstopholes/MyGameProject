extends DebugCommand


func quit():
	executed = false
	GameManager.request_quit = true
	executed = true
