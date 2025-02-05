extends NinePatchRect

var buttons = []
var data = null
var data_path = "user://data.tres"

onready var button = $task_container/task_button.duplicate()
onready var scrollbar = $scrollbar/scroll

var completed = 0
var scroll = 0
var window_drag_hover = false
var window_initial_pos = Vector2.ZERO
var mouse_initial_pos = Vector2.ZERO

onready var original_window_size = OS.window_size
onready var initial_window_size = OS.window_size

var window_resize = false
var note_index = -1

var confetti_completion = preload("res://misc/complete_confetti.tscn")
var confetti_check = preload("res://misc/confetti_check.tscn")

func window_input(delta):
	if window_drag_hover:
		if Input.is_action_just_pressed("CLICK"):
			window_initial_pos = OS.window_position
			mouse_initial_pos = get_local_mouse_position()
			
		if Input.is_action_pressed("CLICK"):
			OS.window_position += ((((get_local_mouse_position() - mouse_initial_pos) * 4) + window_initial_pos) - OS.window_position) * 0.5
			
			OS.window_position.x = clamp(OS.window_position.x,0,1920 - OS.window_size.x)
			OS.window_position.y = clamp(OS.window_position.y,0,1080 - OS.window_size.y)
			
			
	if Input.is_action_just_released("CLICK"):
		window_resize = false

func _ready() -> void:
	
	if ResourceLoader.load(data_path) == null:
		ResourceSaver.save(data_path,preload("res://misc/data.tres"))
	
	data = ResourceLoader.load(data_path)
	
	get_tree().get_root().transparent_bg = true
	$task_container/task_button.queue_free()
	
	evaluate_tasks()
	
func _input(event: InputEvent) -> void:
	
	if $window_manager/exit.is_clicked():
		get_tree().quit()
		
	if $window_manager/minimize.is_clicked():
		OS.window_minimized = true
	
	if $task_container/new/btn_new.is_clicked():
		new_task()
		
	if $note/exit.is_clicked():
		note_index = -1
	
	if get_local_mouse_position().x < 282:
		if Input.is_action_pressed("SCROLL_DOWN"):
			scroll -= 22
			
		if Input.is_action_pressed("SCROLL_UP"):
			scroll += 22
	
func _physics_process(delta: float) -> void:
	
	if note_index != -1:
		$note.rect_position = $note.rect_position.linear_interpolate(Vector2(281,2),delta * 10)
	else:
		$note.rect_position = $note.rect_position.linear_interpolate(Vector2(497,2),delta * 10)
	
	window_input(delta)
	$task_container.rect_position.y += (scroll - $task_container.rect_position.y) * 0.3
	
	$bar.value += ((completed ) - $bar.value) * 0.2
	
	if buttons != []:
		$task_container/new.position.y += (buttons.back().position.y - $task_container/new.position.y) * 0.2
	else:
		$task_container/new.position.y /= 1.1
	
	for i in range(buttons.size()):
		var p = buttons[i]
		p.position = p.position.linear_interpolate($task_container/anchor.position + Vector2(0,i * 22),delta * 15)
	
		if p.get_node("is_done").is_clicked():
			data.checks[i] = !data.checks[i]
			update_info()
			
func remove_check(to_delete = null):
	var caught_index = 0
	for i in range(buttons.size()):
		if buttons[i] == to_delete:
			caught_index = i
			
	var caught_button = buttons[caught_index]
	data.checks.pop_at(caught_index)
	data.names.pop_at(caught_index)
	data.notes.pop_at(caught_index)
	
	buttons.pop_at(caught_index)
	caught_button.queue_free()
	$type.play()
	
	ResourceSaver.save(data_path,data)
	ResourceLoader.load(data_path)
	update_info()

func note_load(btn_selected = null):
	for i in range(buttons.size()):
		if buttons[i] == btn_selected:
			note_index = i
			
	$note/tasknote.text = data.notes[note_index]
	$note/title.text = data.names[note_index]
	$note.rect_position.x = 450
	
func new_task(task_name = ""):
	
	data.names.append("")
	data.checks.append(false)
	data.notes.append("")
	
	ResourceSaver.save(data_path,data)
	ResourceLoader.load(data_path)
	
	evaluate_tasks()
	note_index = -1

func save_info():
	for i in range(data.names.size()):
		var p = buttons[i]
		data.names[i] = p.get_node("button/task").text
		data.checks[i] = p.get_node("is_done/check").visible
		
	ResourceSaver.save(data_path,data)

func update_info():
	
	$bar.max_value = buttons.size()
	completed = 0
	
	for i in range(data.names.size()):
		var p = buttons[i]
		data.names[i] = p.get_node("button/task").text
		p.get_node("button/task").release_focus()
		if data.checks[i]:
			completed += 1
			p.get_node("is_done/check").show()
		else:
			p.get_node("is_done/check").hide()
			
	if completed != 0:
		$bar/percentage.text = str(floor((completed / $bar.max_value) * 100.0),"%")
		
		if completed >= $bar.max_value:
			$bar.modulate = Color.green
			$task_window.text = str(completed, "/", $bar.max_value, " Tasks done, Good work!!!")
			$task_window.modulate = Color.darkgreen
			var complete_confetti_inst = confetti_completion.instance()
			add_child(complete_confetti_inst)
			for i in range(buttons.size()):
				buttons[i].get_node("button/ColorRect").self_modulate = Color(0,(i * 55) + 50,0)
		else:
			$bar.modulate = Color.darkgray
			$task_window.modulate = Color.black
			$task_window.text = str(completed, "/", $bar.max_value, " Tasks done, Keep at it!")
	else:
		$bar/percentage.text = str(0,"%")
		$bar.modulate = Color.darkgray
		$task_window.modulate = Color.black
		$task_window.text = str(completed, "/", $bar.max_value, " Tasks done, Keep at it!")
	
func evaluate_tasks():
	data = ResourceLoader.load(data_path)
	
	for i in buttons:
		i.queue_free()
		
	buttons = []
	
	for i in range(data.names.size()):
		var taskbutton_inst = button.duplicate()
		if data.names[i] != "":
			taskbutton_inst.get_node("button/task").text = data.names[i]
		else:
			taskbutton_inst.get_node("button/task").placeholder_text = str("task #", i + 1)
		taskbutton_inst.position = $task_container/anchor.position + Vector2(0, i * 22)
		$task_container.add_child(taskbutton_inst)
		
		buttons.append(taskbutton_inst)
		
	update_info()

	
func _on_window_manager_mouse_entered() -> void:
	window_drag_hover = true

func _on_window_manager_mouse_exited() -> void:
	window_drag_hover = false

var last_length = 0
func _on_tasknote_text_changed() -> void:
	data.notes[note_index] = $note/tasknote.text
	if last_length > $note/tasknote.text.length():
		$type.pitch_scale = 3
		$type.play()
		last_length = $note/tasknote.text.length()
	else:
		$type.pitch_scale = 1.5 
		$type.play()
		last_length = $note/tasknote.text.length()
		
		
	ResourceSaver.save(data_path,data)

	
