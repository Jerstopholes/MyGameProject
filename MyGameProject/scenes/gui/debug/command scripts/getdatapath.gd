extends DebugCommand


func getdatapath():
	executed = false
	output_text(str("Data files are stored in: [color=green][url]", OS.get_user_data_dir(), "[/url][/color]"))
	debug_log("Succesfully returned the user's data path.")
	executed = true

