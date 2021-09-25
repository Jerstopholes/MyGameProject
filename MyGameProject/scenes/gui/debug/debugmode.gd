extends DebugCommand


func debugmode(arg):
	if arg == "on":
		GameManager.debugmode = true
		output_text('"debugmode on" Executed succesfully!')
		return
	if arg == "off":
		GameManager.debugmode = false
		output_text('"debugmode off" Executed succesfully!')
		return
	else:
		output_text(str("[color=red]ERROR[/color]: ", 'Could not execute "debugmode"!\n', 
		'The specified parameter of "', arg, '" is not correct! Use either "on" or "off".'))
		return
		
