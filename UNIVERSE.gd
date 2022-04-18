extends Control

onready var food := preload("food.tscn")
onready var copy := preload("res://herbivore.tscn")
onready var copy_p := preload("res://predator.tscn")
onready var screen_resolution: Vector2 = OS.window_size * $Camera2D.zoom.x


var name_history: Array = [""]
var max_foods: int = 800
var foods: Array = []
const NAMES = ["крутые", "челы", "ауешники", "меценаты", "трагладиты", "туниядцы", "бездомные", "сироты", "проститутки", "гуси", "майнкрафтеры", "умственно_отсталые", "любители_бананов", "анимешники", "вкусные", "богатые"]
const FIRST_CELLS: int = 30
const FIRST_CELLS_P: int = 0
const MATERIAL: int = 10000
const STANDART: Dictionary = {
	"color": Color(0),
	"name": "",
	"speed": 7500,
	"scale": 1,
	"killing": false
}
const STANDART_P: Dictionary = {
	"speed": 8000
}

func _ready() -> void:
	randomize()
	$StartWait.start()
	yield($StartWait, "timeout")
	for i in FIRST_CELLS:
		var dict = STANDART.duplicate()
		dict["speed"] = rand_range(3000, 6000)
		dict["scale"] = rand_range(0.5, 1.5)
		if randi() % 15 == 5:
			dict["killing"] = true
		dict.color = Color(randf(), randf(), randf(), 1)
		while dict["name"] in name_history:
			for j in int(rand_range(2, 4)):
				var names_plus = NAMES[randi()%NAMES.size()]
				while names_plus in dict["name"]:
					names_plus = NAMES[randi()%NAMES.size()]
				dict["name"] += "_" + names_plus
		name_history.append(dict["name"])
		make_new(Vector2(rand_range(0, screen_resolution.x), rand_range(0, screen_resolution.y)), dict)
	for i in FIRST_CELLS_P:
		make_new_p(Vector2(rand_range(0, screen_resolution.x), rand_range(0, screen_resolution.y)), STANDART_P)


func _process(delta) -> void:
	if $Foods.get_child_count() < max_foods:
		var f = food.instance()
		f.set_global_position(Vector2(rand_range(0, screen_resolution.x), rand_range(0, screen_resolution.y)))
		$Foods.add_child(f)
		foods.append(f)


func _input(event) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			match event.scancode:
				KEY_KP_ADD:
					max_foods += 10
				KEY_KP_SUBTRACT:
					max_foods -= 10
				KEY_KP_ENTER:
					max_foods = 200
				KEY_SPACE:
					make_new_p(Vector2(rand_range(0, screen_resolution.x), rand_range(0, screen_resolution.y)),
						{"speed": 10000})
				KEY_N:
					var dict = STANDART.duplicate()
					dict["speed"] = rand_range(3000, 6000)
					dict["scale"] = rand_range(0.5, 1.5)
					if randi() % 15 == 5:
						dict["killing"] = true
					dict.color = Color(randf(), randf(), randf(), 1)
					while dict["name"] in name_history:
						for j in int(rand_range(2, 4)):
							var names_plus = NAMES[randi()%NAMES.size()]
							while names_plus in dict["name"]:
								names_plus = NAMES[randi()%NAMES.size()]
							dict["name"] += "_" + names_plus
					name_history.append(dict["name"])
					make_new(Vector2(rand_range(0, screen_resolution.x), rand_range(0, screen_resolution.y)), dict)
			print(max_foods)


func _unhandled_key_input(event):
	match event.scancode:
		KEY_SPACE:
			make_new_p(Vector2(rand_range(0, screen_resolution.x), rand_range(0, screen_resolution.y)), STANDART_P) 


func make_new(pos, dna: Dictionary) -> void:
	var c = copy.instance()
	c.set_global_position(pos)
	c.dna(dna)
	add_child(c)


func make_new_p(pos, dna: Dictionary) -> void:
	var c = copy_p.instance()
	c.set_global_position(pos)
	c.dna(dna)
	add_child(c)
	


func _on_UpdateInfo_timeout() -> void:
	var count: int = 0
	var summ: int = 0
	var scale_sum: float = 0
	var biggest_kind: Dictionary = {}
	for cell in get_tree().get_nodes_in_group("herbivore"):
		count += 1
		scale_sum += cell.scale.x
		summ += cell.speed
		if biggest_kind.has(cell.kind_name):
			biggest_kind[cell.kind_name] += 1
		else:
			biggest_kind[cell.kind_name] = 1
	var best_kind: Array = ["", 0]
	for key in biggest_kind.keys():
		if biggest_kind[key] > best_kind[1]:
			best_kind[0] = key
			best_kind[1] = biggest_kind[key]
	if count != 0:
		$CenterContainer/Label.bbcode_text = (
			"[center]Травоядные\nОбщее кол-во - {count}\nСредняя Скорость: {middle}\nСредний размер: {midScale}\nЛучший вид: [color=#{color}]{bestKind}[/color], их кол-во: {bestKindNumber}".format(
			{"count": count, "middle": (summ/count), "midScale": (scale_sum/count), "bestKind": best_kind[0], "bestKindNumber": best_kind[1], "color": get_tree().get_nodes_in_group(best_kind[0])[0].main_color}))
	count = 0
	summ = 0
	for cell in get_tree().get_nodes_in_group("predator"):
		count += 1
		summ += cell.speed
	if count != 0:
		$CenterContainer/Label.bbcode_text += "\n\nХищники\nСредняя скорость: {middle}\nКол-во - {count}".format({"middle":(summ/count), "count":count})
	$CenterContainer/Label.bbcode_text += "[/center]"
