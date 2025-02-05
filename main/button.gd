extends NinePatchRect
class_name btn

onready var right = margin_right
onready var left = margin_left
onready var up = margin_top
onready var down = margin_bottom

var hover = false
var just_hovered = false

export var hide_colorect = false
onready var children = get_children()

export var hover_sfx = preload("res://misc/sfx/click_light.wav")
export var hover_sfx_pitch = 2

export var click_sfx = preload("res://misc/sfx/click_light.wav")
export var click_sfx_pitch = 3

export var release_sfx = preload("res://misc/sfx/click_light.wav")
export var release_sfx_pitch = 1


export var hover_expand = 0.3

func _ready() -> void:
	$ColorRect/hover.stream = hover_sfx
	$ColorRect/hover.pitch_scale = hover_sfx_pitch
	$ColorRect/click.stream = click_sfx
	$ColorRect/click.pitch_scale = click_sfx_pitch
	$ColorRect/release.stream = release_sfx
	$ColorRect/release.pitch_scale = release_sfx_pitch
	
	if hide_colorect:
		$ColorRect.hide()

func _physics_process(delta: float) -> void:
	margin_right += (right - margin_right) * 0.2
	margin_left += (left - margin_left) * 0.2
	margin_top += (up - margin_top) * 0.2
	margin_bottom += (down - margin_bottom) * 0.2
	
	if hover:
		margin_right += hover_expand
		margin_left -= hover_expand + 0.05
		margin_top -= hover_expand + 0.05
		margin_bottom += hover_expand
		$ColorRect.self_modulate = $ColorRect.self_modulate.linear_interpolate(Color(1,1,1,1),delta * 15)
		
		if Input.is_action_just_pressed("CLICK"):
			$ColorRect/click.play()
		
		if Input.is_action_pressed("CLICK"):
			
			margin_right = right + 1
			margin_left = left - 1
			margin_top = up - 1
			margin_bottom = down + 1
			$ColorRect.self_modulate = Color(0.4,0.4,0.4,1)
			self_modulate = Color.black
		else:
			self_modulate = Color.white
			$ColorRect.self_modulate += Color(2,2,2,1) * delta
			
		if Input.is_action_just_released("CLICK"):
			$ColorRect/release.play()
			$ColorRect.self_modulate = Color(1,1,1,0.7)
			margin_right = right + 3
			margin_left = left - 3
			margin_top = up - 3
			margin_bottom = down + 3
	else:
		$ColorRect.self_modulate = $ColorRect.self_modulate.linear_interpolate(Color(0,0,0,0.7),delta * 15)
		
func _on_button_mouse_entered() -> void:
	$ColorRect/hover.play()
	hover = true
	$ColorRect.modulate = Color.white
#	$icon.modulate = Color.white
	for i in children:
		i.self_modulate = Color.black
	
func _on_button_mouse_exited() -> void:
	hover = false
	self_modulate = Color.white

	for i in children:
		i.self_modulate = Color.white
	
func is_clicked():
	if hover and Input.is_action_just_released("CLICK"):
		return true
	else:
		return false

func is_clicking():
	if hover and Input.is_action_pressed("CLICK"):
		return true
	else:
		return false

func is_just_clicked():
	if hover and Input.is_action_just_pressed("CLICK"):
		return true
	else:
		return false

func is_right_clicked():
	if hover and Input.is_action_just_released("RIGHT_CLICK"):
		return true
	else:
		return false
