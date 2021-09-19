extends Control


# Called when the node enters the scene tree for the first time.
func _ready():

	
	# Since this only happens during scene loading, update the WorldName label here
	$InfoPanel/WorldName.text = "Level name = " + get_parent().name
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Toggle the display of the debug screen
	$InfoPanel.visible = GameManager.debugmode
		
