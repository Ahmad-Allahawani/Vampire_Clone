extends Area2D

@export_enum("cooldown", "hitOnce", "DisableHitBox") var hrutbBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disable_timer = $DisableTimer

signal hurt(damage, angle , knockBack)


var hitOnce_Array=[]

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match hrutbBoxType :
				0:#cooldown
					collision.call_deferred("set","disabled",true)
					disable_timer.start()
				1:#hitOnce
					if hitOnce_Array.has(area)== false:
						hitOnce_Array.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array",Callable(self,"remove_from_list")):
								area.connect("remove_from_array",Callable(self,"remove_from_list"))
					else:
						return
				2:#DisableHitBox
					if area.has_method("tempdisable"):
						area.temdisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knockBack_amount") ==null:
				knockback = area.knockBack_amount
			
			emit_signal("hurt",damage,angle,knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)
			
func remove_from_list(object):
	if hitOnce_Array.has(object):
		hitOnce_Array.erase(Object)
func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)








