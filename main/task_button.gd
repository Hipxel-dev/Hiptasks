extends Node2D

var delete = false
var confetti = preload("res://misc/confetti_check.tscn")

func _on_task_text_entered(new_text: String) -> void:
	get_parent().get_parent().update_info()

func _physics_process(delta: float) -> void:
	if $button.is_clicked():
		get_parent().get_parent().note_load(self)
		
	if $is_done.is_clicked() and $is_done/check.visible:
		var confetti_inst = confetti.instance()
		confetti_inst.global_position = $is_done.rect_global_position + Vector2(5,5)
		get_parent().get_parent().save_info()
		
		get_parent().get_parent().add_child(confetti_inst)
		
	if $button.hover and Input.is_action_pressed("ALT_CLICK"):
		$button/dlt.rect_size.x += 15
		$delete.play()
		$delete.pitch_scale = 1 + $button/dlt.rect_size.x / 55
		if $button/dlt.rect_size.x > 221:
			$button/dlt.rect_size.x = 300
			if delete == false:
				get_parent().get_parent().remove_check(self)
				delete = true
				
	else:
		delete = false
		$button/dlt.rect_size.x /= 1.1
		
func _on_task_text_changed(new_text: String) -> void:
	get_parent().get_parent().save_info()
