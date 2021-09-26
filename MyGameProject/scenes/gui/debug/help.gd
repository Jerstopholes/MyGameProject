extends DebugCommand


func help():
	executed = false
	output_text(str("[color=lime]Welcome to the Debug Console![/color] \n",
	"To use the debug console, enter any valid commands along with ",
	'their required parameter(s).',
	'\nTo get a list of valid commands, use [color=teal]list[/color].',
	'\nPay close attention to the parameters listed along with the command name. Parameters',
	' are enclosed with angle brackets like so:  "<parameter>".',
	'\nIf you want to view the command history, use [color=blue]CTRL+UP[/color] or [color=blue]CTRL+DOWN[/color] on your keyboard.',
	'\nTo execute the command again, just hit "Enter"!'))
	executed = true
