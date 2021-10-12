extends ConfirmationDialog


func _process(_delta):
	if GameManager.request_quit:
		GameManager.request_quit = false
		self.popup_centered()

func _on_QuitBox_confirmed():
	get_tree().quit()
