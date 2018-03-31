extends AudioStreamPlayer

export (AudioStream) var level_music = null # Play this during the gameplay.

func _ready():
	self.play()
