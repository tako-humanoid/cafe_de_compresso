extends Control
var cup_size = 0
var plugin
var convert_ready = false
var _raw_image : Image = null

func _ready() -> void:
	if Engine.has_singleton("FooBar"):
		plugin = Engine.get_singleton("FooBar")
		#var msg = plugin.helloWorld()
		
		plugin.connect("file_selected_path", _on_path_received)
		
		#print (msg)
		
	else: 
		print("I'm afraid but I cannot load plugin...")


func _on_path_received(path: String):
	var clean_path = path.replace("file://", "")
	var file = FileAccess.open(clean_path, FileAccess.READ)
	if not file:
		print("couldnt open file :", FileAccess.get_open_error())
		return
	
	var img = Image.load_from_file(path)
	if img :
		_raw_image = img
		
		convert_ready = true
		$MarginContainer/VBoxContainer/BT_brew.material.set_shader_parameter("bright",1.0)

func apply_color_buttons():
	$MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/BT_short.material.set_shader_parameter("bright",1.0 if cup_size == 0 else 0.5)
	$MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/BT_tall.material.set_shader_parameter("bright",1.0 if cup_size == 1 else 0.5)
	$MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/BT_grande.material.set_shader_parameter("bright",1.0 if cup_size == 2 else 0.5)


func _on_bt_short_pressed() -> void:
	cup_size = 0
	apply_color_buttons()
	
func _on_bt_tall_pressed() -> void:
	cup_size = 1
	apply_color_buttons()

func _on_bt_grande_pressed() -> void:
	cup_size = 2
	apply_color_buttons()


func _on_bt_select_pressed() -> void:
	
	plugin.openNativeFilePicker()
	pass # Replace with function body.


func _on_bt_brew_pressed() -> void:
	if convert_ready == true:
		var resized_img = _raw_image.duplicate()
		var quality = 0.8
		var max_pixel = 0
		match cup_size:
			0: 
				#target_width = 720
				max_pixel = 800
				quality = 0.65
			1: 
				#target_width = 1152
				max_pixel = 1280
				quality = 0.75
			2: 
				max_pixel = 1920
				#target_width = 1920
				quality = 0.80
			
		var width = resized_img.get_width()
		var height = resized_img.get_height()
		
		print("Before: ", resized_img.get_size(), " MaxTarget: ", max_pixel)
		
		var new_w = 0
		var new_h = 0
		#resized_img.resize(800	,0,Image.INTERPOLATE_LANCZOS)
		if width > height:
			if width > max_pixel:
				new_w = max_pixel
				new_h = int(float(height) / width * max_pixel)
		else:
			if height > max_pixel:
				new_h = max_pixel
				new_w = int(float(width) / height * max_pixel)
				
		new_w = max(new_w, 1)
		new_h = max(new_h, 1)
		
		resized_img.resize(new_w,new_h, Image.INTERPOLATE_LANCZOS)
		
		print("after resize: ", resized_img.get_size())
		
		var datetime = Time.get_datetime_dict_from_system()
		var timestamp = "%04d%02d%02d_%02d%02d%02d" % [
			datetime.year,
			datetime.month,
			datetime.minute,
			datetime.hour,
			datetime.minute,
			datetime.second
		]
		
		var size_name = ["short","tall","grande"][cup_size]
		var save_path = "user://brew_" + timestamp + "_" + size_name + ".jpg"
		var err = resized_img.save_jpg(save_path, quality)
		if err == OK:
			var absolute_path = ProjectSettings.globalize_path(save_path)
			
			if plugin:
				print("sharing")
				plugin.shareImage(absolute_path)
			else:
				print("failed to load")
				
		else:
			print ("failed to save")
		
		pass
	pass # Replace with function body.
