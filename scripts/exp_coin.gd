extends Area2D

@export var experience = 1

var spr_yellow = preload("res://ASS/texture/coin_yellow.png")
var spr_green = preload("res://ASS/texture/coin_green_1.png")
var spr_red = preload("res://ASS/texture/coin_red_1.png")

var target = null 
var speed =-1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var snd = $snd_collected

func _ready():
	if experience < 5 :
		return
	elif experience <25 :
		sprite.texture = spr_green
	else :
		sprite.texture = spr_red
		
func _physics_process(delta):
	if target != null :
		global_position = global_position.move_toward(target.global_position,speed)
		speed += 2*delta


func collect():
	snd.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return experience


func _on_snd_collected_finished():
	queue_free()
