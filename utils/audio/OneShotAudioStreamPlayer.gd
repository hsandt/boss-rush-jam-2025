# from https://github.com/hsandt/hyper-godot-commons/blob/main/audio/OneShotAudioStreamPlayer.gd
class_name OneShotAudioStreamPlayer
extends AudioStreamPlayer
## Subclass of AudioStreamPlayer that frees itself when audio stream has finished playing
## Also offers a utility method to play an audio stream
## Generally used for one-shot SFX
##
## Usage:
## - create scene OneShotAudioStreamPlayer.tscn with one node with this script
##   (the easiest is to copy/inherit from scene OneShotAudioStreamPlayerTemplate.tscn)
## - customize OneShotAudioStreamPlayer.tscn, in particular the Bus
##   to match the type of SFX to play on this instance
## - instantiate that scene at runtime and call play_audio_stream on it
##   (the easiest is to use the provided SFXManager)


func _ready():
	finished.connect(_on_finished)


func play_audio_stream(audio_stream: AudioStream):
	stream = audio_stream
	play()


func _on_finished():
	queue_free()
