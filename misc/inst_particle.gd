extends CPUParticles2D

func _ready() -> void:
	emitting = true
	
	
func _physics_process(delta: float) -> void:
	if emitting == false:
		queue_free()
