extends KinematicBody2D

enum States {SEARCH, CHASE}

var speed: int = 7500
var state: int = States.SEARCH
var stamina: float = 1999
var max_stamina: int = 2500
var consumption: float = 0.1
var health: int = 100 setget minus_health
var killing: bool = false

var kind_name: String = ""

var vel: Vector2 = Vector2.ZERO

var body: Object

var main_color: String


func _ready() -> void:
	add_to_group("herbivore")


func _process(delta) -> void:
	stamina -= consumption
#	print(stamina)
	match state:
		States.SEARCH:
			var nearest: Object
			for food in get_parent().foods:
				if !is_instance_valid(nearest):
					nearest = food
				elif self.global_position.distance_squared_to(food.global_position) < self.global_position.distance_squared_to(nearest.global_position):
					nearest = food
			body = nearest
			state = States.CHASE
		States.CHASE:
			if is_instance_valid(body):
				rotation = lerp(rotation, atan2(vel.y, vel.x), 0.1)
				vel = self.global_position.direction_to(body.global_position)
				var _mas = move_and_slide(vel * speed * delta)
			else:
				state = States.SEARCH


func dna(code: Dictionary) -> void:
	randomize()
	$sprite.modulate = code["color"]
	main_color = code["color"].to_html(false)
	kind_name = code["name"]
	speed = abs(code["speed"] + rand_range(-500, 500))
	killing = code["killing"]
	var new_scale: float = abs(code["scale"] + rand_range(-0.5, 0.5))
	health *= new_scale
	scale = Vector2(new_scale, new_scale)
	consumption = speed * 0.0003
	max_stamina = scale.x * 2500
	add_to_group(kind_name)
#	print(kind_name, ": SPEED " ,speed, " | SIZE ", new_scale, " | C ", consumption, " | MaxStamina ", max_stamina)


func _on_Food_area_entered(area) -> void:
	if area.is_in_group("food"):
		stamina += 400
		if stamina > max_stamina:
			stamina = max_stamina
		get_parent().foods.remove(get_parent().foods.find(area))
		area.free()


func _on_Food_body_entered(body) -> void:
	if body.is_in_group("herbivore") and body.kind_name != self.kind_name:
		body.health -= 10
		position -= global_position.direction_to(body.global_position) * 10
		body.position -= body.global_position.direction_to(global_position) * 10
		health -= 10


func _on_MakeNew_timeout() -> void:
	if stamina >= max_stamina - 500:
		get_parent().make_new(self.global_position, {
				"color": $sprite.modulate,
				"name": kind_name,
				"speed": speed,
				"scale": scale.x,
				"killing": killing
		})
		stamina = max_stamina - 501
	elif stamina <= 0:
		queue_free()


func minus_health(value) -> void:
	health = value
	if health <= 0:
		queue_free()
