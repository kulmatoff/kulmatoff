extends KinematicBody2D

enum States {SEARCH, CHASE}

var speed: int = 8000
var state: int = States.SEARCH

var stamina: float = 1999
var consumption: float = 0.1

var vel: Vector2 = Vector2.ZERO

var body: Object


func _ready() -> void:
	add_to_group("predator")


func _process(delta) -> void:
	stamina -= consumption
	match state:
		States.SEARCH:
			var nearest: Object
			for food in get_tree().get_nodes_in_group("herbivore"):
				if !is_instance_valid(nearest):
					nearest = food
				elif self.global_position.distance_squared_to(food.global_position) < self.global_position.distance_squared_to(nearest.global_position):
					nearest = food
			body = nearest
			state = States.CHASE
		States.CHASE:
			var nearest: Object
			for food in get_tree().get_nodes_in_group("herbivore"):
				if !is_instance_valid(nearest):
					nearest = food
				elif self.global_position.distance_squared_to(food.global_position) < self.global_position.distance_squared_to(nearest.global_position):
					nearest = food
			body = nearest
			if is_instance_valid(body):
				vel = self.global_position.direction_to(body.global_position)
			else:
				state = States.SEARCH
			move_and_slide(vel * speed * delta)


func dna(code: Dictionary) -> void:
	randomize()
	speed = code["speed"] + rand_range(-500, 500)
	consumption = speed * 0.0003
#	print(speed, " | ", consumption)


func _on_Food_body_entered(body_) -> void:
	if body_.is_in_group("herbivore"):
		stamina += 100
		if stamina > 2500:
			stamina = 2500
		body_.free()


func _on_MakeNew_timeout() -> void:
	if stamina >= 2000:
		get_parent().make_new_p(self.global_position, {
				"speed": speed
		})
		stamina = 1999
	elif stamina <= 0:
		queue_free()
