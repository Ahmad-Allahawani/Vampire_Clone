extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var movement_speed = 20.0
@export var knockBack_recovery = 3.5
@export var experience = 1
@export var damage = 1
var knockBack = Vector2.ZERO
@export  var hp = 10
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var collision = $CollisionShape2D
@onready var hit_box = $hitBox


#sound
@onready var sound_hit = $sound_hit
@onready var death_sound = $death_sound
#timer
@onready var death_delay = $death_delay

var exp_coin = preload("res://scenes/exp_coin.tscn")
signal remove_from_array(object)


func _ready():
	hit_box.damage = damage

func _physics_process(delta):
	if hp >0:
		knockBack = knockBack.move_toward(Vector2.ZERO, knockBack_recovery)
		var direction = global_position.direction_to(player.global_position)
		velocity = direction*movement_speed
		velocity += knockBack
	
		#move_and_slide()
		move_and_collide(velocity * delta);
	
		if direction.x > 0.1:
			animated_sprite.flip_h = false
		
		elif direction.x < -0.1:
			animated_sprite.flip_h = true
	
	
		if direction.x == 0 :
			animated_sprite.play("idle")
		else:
			animated_sprite.play("move")
	
	


func _on_hurt_box_hurt(damage,angle , knockBack_amount):
	hp-=damage
	knockBack = angle * knockBack_amount
	
	if hp <= 0  :
		animated_sprite.play("death")
		emit_signal("remove_from_array",self)
		death_sound.play()
		death_delay.start()
	else:
		sound_hit.play()
	print(hp)
	
func spawn_coin():
	var new_coin = exp_coin.instantiate()
	new_coin.global_position = global_position
	new_coin.experience = experience
	get_parent().add_child(new_coin)

func _on_death_delay_timeout():
	spawn_coin()
	queue_free()
	
