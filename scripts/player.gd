extends CharacterBody2D
#movement for fun code var{
#var speed = 80
#var click_position = Vector2()
#var target_position = Vector2()
#}

var movement_speed = 50.0
var hp = 100
var maxhp = 100
var last_movement = Vector2.UP
var time = 0

var experience = 0
var exp_level = 1
var collected_exp = 0
#attaks
var purpFire = preload("res://scenes/purp_fire.tscn")
var Tornado = preload("res://scenes/tornado.tscn")
var Javelin = preload("res://scenes/javelin.tscn")

#AttackNodes
@onready var purpFireTimer = get_node("attack/purp_fire_timer")
@onready var purpFireAttackTimer = get_node("attack/purp_fire_timer/purp_fire_attack_timer")
@onready var tornadoTimer = get_node("%Tornado_timer")
@onready var tornadoAttackTimer =get_node("attack/Tornado_timer/TornadoAttack_timer")
@onready var JavelinBase = get_node("%JavelinBase")






#purpFire
var purpFire_ammo= 0
var purpFire_baseammo=0
var purpFire_attackspeed = 1.5
var purpFire_level = 1

#tornado
var tornado_ammo= 0
var tornado_baseammo=0
var tornado_attackspeed = 3
var tornado_level = 1

#Javelin
var Javelin_ammo = 0
var Javelin_level = 1

#enmey related
var enemy_close = []

@onready var animated_sprite = $AnimatedSprite2D

#GUI
@onready var xp_bar = get_node("%XP_BAR")
@onready var label_level = get_node("%Label_level")
@onready var level_panel =get_node("%level_up")
@onready var lbl_level_up = get_node("%lbl_levelUP")
@onready var upgradeOptions = get_node("%upgradeOptions")
@onready var snd_level_up = get_node("%snd_levelUP")
@onready var ItemOption = preload("res://scenes/Item_option.tscn")
@onready var health_bar = get_node("%HealthBar")
@onready var lbl_timer = get_node("%lbl_timer")
@onready var collectedWeapons = get_node("%collectedWepons")
@onready var collectedUpgrades  = get_node("%collectedUpgrads")
@onready var itemContainer = preload("res://scenes/item_container.tscn")

#Upgrades
var collected_upgrades =[]
var upgrade_options =[]
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks =0


func _ready():
	upgradeCharacter("purplefire1")
	attack()
	set_xpBar(experience, calculate_experienceCAP())
	_on_hurt_box_hurt(0,0,0)
	
func _physics_process(delta):
	#movement for fun code{
	#if Input.is_action_just_pressed("left_click"):
		#click_position =get_global_mouse_position()
		#animated_sprite.play("move")
		
		
	#if position.distance_to(click_position)>3:
		#target_position = (click_position-position).normalized()
		#velocity = target_position*speed
		#move_and_slide()
	#else:
		#animated_sprite.play("idle")
		
	#if target_position.x<0:
		#animated_sprite.flip_h=true
	#else:
		#animated_sprite.flip_h=false
									#}
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	if mov.x> 0 :
		animated_sprite.flip_h = false
	elif mov.x < 0 :
		animated_sprite.flip_h = true
	
	
	if mov.x == 0 and mov.y==0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("move")
	
	velocity = mov.normalized()* movement_speed
	
	if mov != Vector2.ZERO:
		last_movement=mov
	
	move_and_slide()

func attack():
	if purpFire_level >0:
		purpFireTimer.wait_time = purpFire_attackspeed * (1-spell_cooldown)
		if purpFireTimer.is_stopped():
			purpFireTimer.start()
	if tornado_level >0:
		tornadoTimer.wait_time = tornado_attackspeed* (1-spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if Javelin_level >0:
		spawn_Javelin()


func _on_hurt_box_hurt(damage,_anlge,_knockBack):
	hp -= clamp(damage -armor,1.0,999.0)
	health_bar.max_value = maxhp
	health_bar.value = hp

func _on_purp_fire_timer_timeout():
	purpFire_ammo += purpFire_baseammo +additional_attacks
	purpFireAttackTimer.start()


func _on_purp_fire_attack_timer_timeout():
	if purpFire_ammo>0:
		var purpFire_attack = purpFire.instantiate()
		purpFire_attack.global_position =global_position
		purpFire_attack.target= get_random_target()
		purpFire_attack.level = purpFire_level
		add_child(purpFire_attack)
		purpFire_ammo -=1
		if purpFire_ammo>0:
			purpFireAttackTimer.start()
		else:
			purpFireAttackTimer.stop()
			
func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo +additional_attacks
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout():
	if tornado_ammo>0:
		var tornado_attack = Tornado.instantiate()
		tornado_attack.global_position =global_position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -=1
		if tornado_ammo>0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_Javelin():
	var get_javelin_total = JavelinBase.get_child_count()
	var calc_spawns = (Javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0 :
		var javelin_spawn = Javelin.instantiate()
		javelin_spawn.global_position = global_position
		JavelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	#Update javelin
	#Upgrade Javelin
	var get_javelins = JavelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_Javelin"):
			i.update_Javelin()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP




func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
	



func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var coin_xp = area.collect()
		calculate_experience(coin_xp)

func calculate_experience(coin_xp):
	var exp_required = calculate_experienceCAP()
	collected_exp += coin_xp
	if experience + collected_exp >= exp_required: #level up
		collected_exp -= exp_required - experience
		exp_level += 1
		experience = 0
		exp_required = calculate_experienceCAP()
		levelUP()
	else:
		experience += collected_exp
		collected_exp = 0
	set_xpBar(experience, exp_required)

func calculate_experienceCAP():
	var exp_cap = exp_level
	if exp_level < 20:
		exp_cap = exp_level*5
	elif exp_level < 40 :
		exp_cap = 95+(exp_level - 19)*8
	else:
		exp_cap = 255 + (exp_level - 39)*12
		
	return exp_cap

func set_xpBar(set_value = 1 , set_max_value = 100 ):
	xp_bar.value =  set_value
	xp_bar.max_value = set_max_value

func levelUP():
	snd_level_up.play()
	label_level.text = str("level :" ,exp_level)
	var tween = level_panel.create_tween()
	tween.tween_property(level_panel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	level_panel.visible = true
	var option = 0 
	var optionmax = 3
	while option < optionmax:
		var option_choice = ItemOption.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		option += 1
	get_tree().paused = true

func upgradeCharacter(upgrade):
	match upgrade:
		"purplefire1":
			purpFire_level = 1
			purpFire_baseammo += 1
		"purplefire2":
			purpFire_level = 2
			purpFire_baseammo += 1
		"purplefire3":
			purpFire_level = 3
		"purplefire4":
			purpFire_level = 4
			purpFire_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			Javelin_level = 1
			Javelin_ammo  = 1
		"javelin2":
			Javelin_level = 2
		"javelin3":
			Javelin_level = 3
		"javelin4":
			Javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	adjust_gui_collection(upgrade)
	attack()
	
	
	
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	level_panel.visible = false
	level_panel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var dblist=[]
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #to check for the collected Upgrades
			pass 
		elif i in upgrade_options :#if the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #dont pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() >0 :#check for prerequisite
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() >0:
		var RandomItme = dblist.pick_random()
		upgrade_options.append(RandomItme)
		return RandomItme
	else:
		return null

func changeTimer(argTime = 0):
	time = argTime
	var get_m = int(time/60.0)
	var get_s = time%60
	
	if get_m <10:
		get_m = str(0,get_m)
	if get_s <10:
		get_s = str(0,get_s)
		
	lbl_timer.text = str(get_m,":",get_s)
	
func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)






























