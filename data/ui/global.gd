extends CanvasLayer

@onready var lines: RichTextLabel
@onready var input: LineEdit

var active: bool = true
var history: Array[String]
var h_index := -1
var load_status: int = 0
var load_call: Callable

static var Game: GameRunner

static var DEBUG: bool = false
static var SCN_PLAYER: PackedScene
static var SCN_ENTITY: PackedScene
static var SCN_PROJECTILE: PackedScene
static var SCN_TEXT_POPUP: PackedScene

class TEAM:
	const FRIENDLY: int = 0x0000_0001
	const HOSTILE: int = 0x0000_0010
	const PROJECTILE: int = 0x0000_0100

func _ready() -> void:
	lines = $margin/vbox/lines as RichTextLabel
	input = $margin/vbox/input as LineEdit
	history = []
	input.text_submitted.connect(submit_console)

func _process(_delta: float) -> void:
	if load_status % 3 == 1:
		load_call.call_deferred()
		load_status += 1
	if load_status % 3 == 2: return
	match load_status:
		0: attempt_load(Global.load_resources, "Loading Global Resources")
		#3: attempt_load(Server.load_resources, "Loading Server Resources")
		#6: attempt_load(ProcItem.register_all, "Loading Static Items")
		9: attempt_load(self.cleanup, "Loading R.E.M. Core")
		12: attempt_load(func(): get_tree().change_scene_to_file.call_deferred("res://data/ui/main_menu.tscn"), "Starting Main Menu...")

func attempt_load(load_step: Callable, load_id: String) -> void:
	self.print(load_id)
	load_call = load_step
	load_status += 1

func cleanup() -> void:
	self.print("Finalizing")
	load_status += 1

func load_resources() -> void:
	SCN_PLAYER = load("res://data/game/player.tscn") as PackedScene
	SCN_ENTITY = load("res://data/game/entity.tscn") as PackedScene
	SCN_PROJECTILE = load("res://data/game/projectile.tscn") as PackedScene
	SCN_TEXT_POPUP = load("res://data/ui/text_popup.tscn") as PackedScene
	load_status += 1 +3+3

###################################################################################################################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
###################################################################################################################################################################################

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.is_action("dbg_console") || (event.is_action("esc") && active): call_deferred("toggle_console")
		if event.keycode == KEY_UP:
			h_index = clamp(h_index +1, -1, history.size() -1)
			input.clear()
			if h_index != -1: input.insert_text_at_caret(history[h_index])
		if event.keycode == KEY_DOWN:
			h_index = clamp(h_index -1, -1, history.size() -1)
			input.clear()
			if h_index != -1: input.insert_text_at_caret(history[h_index])

func toggle_console() -> void:
	if load_status != -1 && active == true: return
	active = !active
	visible = active
	set_process(active)
	if active:
		input.grab_focus()
		input.text = ""

func submit_console(text: String) -> void:
	input.text = ""
	parse_command(text)
	h_index = -1
	if (history.size() > 0 && history[0] != text) || history.size() == 0: history.push_front(text)

func print(text: String) -> void:
	print_rich("[Console] " + text.replace("\n", "\n          "))
	lines.text += ("\n" if lines.text != "" else "") + text

func print_err(text: String) -> void:
	print_rich("[color=red][Error] " + text.replace("\n", "\n[Error] ") + "[/color]")
	push_error("[Error] " + text.replace("\n", "\n[Error] "))
	lines.text += ("\n" if lines.text != "" else "") + "[color=red]" + text + "[/color]"

func parse_command(text: String) -> void:
	var commands := split_in_same_level(text, ";")
	self.print("< " + text)
	for command in commands:
		var args := split_in_same_level(command, " ")
		while args.size() > 0 && args[0] == "": args.pop_front()
		run_command(args)

var hit_error: bool = false
func run_command(args: Array[String]) -> void:
	hit_error = false
	if args.size() == 0: return
	match args[0]:
		"fps":
			if args.size() < 2: return self.print(" > FPS target: %s (%s mspt), Running: %s" % ["uncapped" if Engine.max_fps == 0 else str(Engine.max_fps),round(1000.0/Engine.max_fps),Engine.get_frames_per_second()])
			Engine.max_fps = int(args[1])
			self.print(" > FPS target set to %s (%s mspt)" % [Engine.max_fps,round(1000.0/Engine.max_fps)])
		"stat_mod" when in_game() && exact_args(args, 2):
			args[1] = args[1].to_upper()
			var idx := Player.string_to_stat(args[1])
			if idx == -1: return print_err(" > Unknown stat name '%s'" % args[1])
			Global.Game.player.stats[idx] = float(args[2])
			self.print(" > Set stat '%s' to '%s'" % [args[1], Global.Game.player.stats[idx]])
		"gun" when in_game() && exact_args(args, 1):
			Game.player.proc.gun.style = int(args[1])
			self.print(" > Set player gun to %s" % args[1])
		_ when !hit_error: print_err(" > Unknown Command '%s'" % args[0])
		_: pass

func exact_args(args: Array[String], count: int) -> bool:
	if args.size() == count+1: return true
	hit_error = true
	print_err(" > Invalid args, expected %s got %s" % [count, args.size()])
	return false

func in_game() -> bool:
	if Game: return true
	hit_error = true
	print_err(" > Must be in-game to use this command")
	return false

func split_in_same_level(text: String, blade: String) -> Array[String]:
	if !text.contains(blade) || text.is_empty(): return [text]
	var ret: Array[String] = []
	var pos: int = 0
	var dist: int = 0
	var stack: Array[String] = []
	while true:
		if pos + dist >= text.length():
			ret.append(text.substr(pos))
			return ret
		var chari: String = text[pos + dist]
		if chari == "\\":
			dist += 2
			continue
		if !stack.is_empty(): if stack[-1] == chari: 
			stack.pop_back()
			dist += 1
			continue
		if stack.is_empty() && text.substr(pos + dist).begins_with(blade):
			ret.append(text.substr(pos, dist))
			pos += dist + 1
			dist = 0
		else:
			match chari:
				"[": stack.append("]")
				"{": stack.append("}")
				"(": stack.append(")")
				"\"": stack.append("\"")
			dist += 1
	# hopefully this code never runs
	print_err("[SISL-NACPRAV]\tinput: '%s'" % text)
	return ["NACPRAV"]
