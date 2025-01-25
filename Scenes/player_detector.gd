extends Area3D

signal player_entered
signal player_exited

func _on_body_entered(body):
	if body is Player:
		emit_signal("player_entered")

func _on_body_exited(body):
	if body is Player:
		emit_signal("player_exited")
