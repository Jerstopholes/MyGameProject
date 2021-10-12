extends DebugCommand

func list():
	executed = false
	var count = 0
	for i in console.get_child_count():
		if console.get_child(i) is DebugCommand:
			count += 1
			if console.get_child(i)._desc == null:
				output_text(str('[color=aqua]', console.get_child(i).name.to_upper(),
					 '[/color] -- [color=red]Does NOT have a description or instructions for its use![/color]'))
			else:
				output_text(str("[color=aqua]", console.get_child(i)._name.to_upper(),
					"[/color] -- ", console.get_child(i)._desc))
	
	output_text(str("[color=fuchsia]Returned ", count, " of ", count, " total commands.[/color]"))
	executed = true
