extends Node2D

@export var spwans :Array[spwan_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0 

signal changeTime(time)

func  _ready():
	connect("changeTime",Callable(player,"changeTimer"))

func _on_timer_timeout():
	time +=1
	var enemy_spwans = spwans
	
	for i in enemy_spwans:
		if time >= i.time_start and time <= i.time_end:
			if i.spwan_delay_counter<i.enemy_spwan_delay:
				i.spwan_delay_counter+=1
			else:
				i.spwan_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter< i.enemy_num:
					var enemy_spwan = new_enemy.instantiate()
					enemy_spwan.global_position = get_random_position()
					add_child(enemy_spwan)
					counter +=1
	emit_signal("changeTime",time)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(0.4,0.8)
	var top_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
	var top_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
	var bottom_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
	var bottom_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos = Vector2.ZERO
	

	#var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	#var top_left = Vector2(player.global_position.x -vpr.x/2 , player.global.position.y - vpr.y/2)
	#var top_right = Vector2(player.global_position.x +vpr.x/2 , player.global.position.y - vpr.y/2)
	#var bottom_left = Vector2(player.global_position.x -vpr.x/2 , player.global.position.y + vpr.y/2)
	#var bottom_right = Vector2(player.global_position.x -vpr.x/2 , player.global.position.y - vpr.y/2)
	#var pos_side = ["up","down","right",'left'].pick_random()
	#var spwan_pos1 = Vector2.ZERO
	#var spwan_pos2 = Vector2.ZERO
	
	#match pos_side:
		#"up":
			#spwan_pos1=top_left
			#spwan_pos2=top_right
		#"down":
			#spwan_pos1 =bottom_left
			#spwan_pos2 =bottom_right
		#"right":
			#spwan_pos1=top_right
			#spwan_pos2=bottom_right
		#"left":
			#spwan_pos1= top_left
			#spwan_pos2= bottom_left
			
	#var x_spwan = randf_range(spwan_pos1.x,spwan_pos2.x)
	#var y_spwan = randf_range(spwan_pos1.y,spwan_pos2.y)
	#return Vector2(x_spwan,y_spwan)
	
	
	match pos_side:
		"up":
			spawn_pos = Vector2(randf_range(top_left.x, top_right.x), top_left.y)
		"down":
			spawn_pos = Vector2(randf_range(bottom_left.x, bottom_right.x), bottom_left.y)    
		"right":       
			spawn_pos = Vector2(top_right.x, randf_range(top_right.y, bottom_right.y))
		"left": 
			spawn_pos = Vector2(top_left.x, randf_range(top_left.y, bottom_left.y))
	return spawn_pos







