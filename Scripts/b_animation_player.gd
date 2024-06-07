class_name AnimationManager
extends AnimationPlayer

var animation_iddle: String

func _process(delta):
	if self.get_queue().is_empty():
		if animation_iddle.is_empty():
			self.stop()
		else: 
			self.play(animation_iddle)

func play_animation(path_animation: String):
	self.play(path_animation)

func stop_animation():
	self.stop()

func add_animation_to_queue(path_animation: String):
	self.queue(path_animation)
