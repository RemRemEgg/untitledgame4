extends Control

@onready var flow_container: FlowContainer = $margin_container/flow_container as FlowContainer
@onready var start_game: Button = flow_container.get_node("start_game") as Button
@onready var level_box: SpinBox = flow_container.get_node("spin_box") as SpinBox


func _ready() -> void:
	start_game.button_up.connect(start_game_pressed)


func start_game_pressed() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(level_box.value)
	rng.state = rng.randi()
	
	var ents: Array[ProcEntity] = []
	
	for i in 5:
		var ent := ProcEntity.create(i, rng.randi())
		ents.append(ent)
	
	GameRunner.ENTITIES = ents
	GameRunner.RNG = RandomNumberGenerator.new()
	GameRunner.RNG.seed = randi()
	
	Limbo.goto(Limbo.GAME_START)
