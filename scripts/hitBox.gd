extends Area2D

@export var damage = 2
@onready var disableTimer = $disableHitBoxTimer
@onready var collision = $CollisionShape2D

func temdisable():
	collision.call_deferred("set","disable",true)
	disableTimer.start()


func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set","disable",false)
