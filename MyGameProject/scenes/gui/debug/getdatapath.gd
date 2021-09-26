extends DebugCommand


func getdatapath():
	executed = false
	output_text(str(OS.get_user_data_dir()))
	debug_log("Succesfully returned the user's data path.")
	executed = true

