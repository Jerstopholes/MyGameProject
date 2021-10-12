extends DebugCommand


func emptyhistory():
	executed = false
	
	if console.get_node("History").items.size() > 0:
		console.get_node("History").items = []
		executed = true
		output_text("Succesfully emptied the command history!")
		return
	else:
		output_text(str(error, "There is nothing to empty out of the command history!"))
		return
