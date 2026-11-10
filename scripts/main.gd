extends Node2D
# المتحكم الرئيسي: القائمة، بناء المراحل، الموت والفوز

const Levels := preload("res://scripts/levels.gd")
const LevelView := preload("res://scripts/level_view.gd")
const Player := preload("res://scripts/player.gd")
const Enemy := preload("res://scripts/enemy.gd")
const Pickup := preload("res://scripts/pickup.gd")
const ExitFlag := preload("res://scripts/exit_flag.gd")
const TouchControls := preload("res://scripts/touch_controls.gd")
const Hud := preload("res://scripts/hud.gd")

const TILE: int = 32

var state: String = "title"   # title, play, dead, gameover, win, end
var level_index: int = 0
var lives: int = 3
var score: int = 0
var world: Node2D = null
var player = null
var controls = null
var hud = null
var message: Label = null
var ui_layer: CanvasLayer = null


func _ready() -> void:
    controls = TouchControls.new()
    add_child(controls)

    ui_layer = CanvasLayer.new()
    ui_layer.layer = 5
    add_child(ui_layer)

    hud = Hud.new()
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_layer.add_child(hud)
    hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    message = Label.new()
    message.mouse_filter = Control.MOUSE_FILTER_IGNORE
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    message.add_theme_font_size_override("font_size", 34)
    message.add_theme_color_override("font_outline_color", Color(0, 0, 0))
    message.add_theme_constant_override("outline_size", 8)
    ui_layer.add_child(message)
    message.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    _show_title()


func _process(_delta: float) -> void:
    hud.lives = lives
    hud.score = score


func _input(event: InputEvent) -> void:
    var go: bool = false
    if event is InputEventScreenTouch and event.pressed:
        go = true
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
            go = true
    if not go:
        return
    if state == "title":
        lives = 3
        score = 0
        level_index = 0
        _start_level()
    elif state == "dead":
        _start_level()
    elif state == "gameover" or state == "end":
        _show_title()
    elif state == "win":
        level_index += 1
        _start_level()


func _show_title() -> void:
    _clear_world()
    state = "title"
    hud.player = null
    hud.visible = false
    controls.visible = false
    RenderingServer.set_default_clear_color(Color(0.1, 0.12, 0.1))
    _set_message("RAMBO III\n\nاضغط على الشاشة للبدء")


func _set_message(text: String) -> void:
    message.text = text
    message.visible = text != ""


func _flash_message(text: String, secs: float) -> void:
    _set_message(text)
    var lvl: int = level_index
    await get_tree().create_timer(secs).timeout
    if state == "play" and level_index == lvl:
        _set_message("")


func _clear_world() -> void:
    if world != null:
        remove_child(world)
        world.queue_free()
        world = null
    player = null


func _start_level() -> void:
    _clear_world()
    var d: Dictionary = Levels.LEVELS[level_index]
    world = Node2D.new()
    add_child(world)
    move_child(world, 0)

    if d["theme"] == "fort":
        RenderingServer.set_default_clear_color(Color(0.85, 0.55, 0.38))
    else:
        RenderingServer.set_default_clear_color(Color(0.45, 0.7, 0.9))

    var width_px: float = float(d["width"] * TILE)

    var view := LevelView.new()
    world.add_child(view)
    view.setup(d["ground"], d["platforms"], width_px, d["theme"])

    # التصادم
    var body := StaticBody2D.new()
    body.collision_layer = 1
    body.collision_mask = 0
    world.add_child(body)
    for g in d["ground"]:
        _add_block(body, g[0], g[2], g[1] - g[0], 18 - g[2])
    for p in d["platforms"]:
        _add_block(body, p[0], p[2], p[1] - p[0], 1)
    _add_block(body, -2, -10, 2, 40)
    _add_block(body, d["width"], -10, 2, 40)

    # النهاية
    var flag := ExitFlag.new()
    world.add_child(flag)
    flag.global_position = Vector2(d["exit"][0] * TILE + 16, d["exit"][1] * TILE - 32)
    flag.reached.connect(_on_exit)

    # الصناديق
    for it in d["ammo"]:
        _add_pickup("ammo", it)
    for it in d["health"]:
        _add_pickup("health", it)

    # اللاعب
    player = Player.new()
    player.controls = controls
    world.add_child(player)
    player.global_position = Vector2(d["start"][0] * TILE + 16, d["start"][1] * TILE - 24)
    player.died.connect(_on_player_died)

    var cam := Camera2D.new()
    cam.limit_left = 0
    cam.limit_right = int(width_px)
    cam.limit_top = 0
    cam.limit_bottom = 544
    cam.position_smoothing_enabled = true
    player.add_child(cam)
    cam.make_current()

    # الأعداء
    for e in d["enemies"]:
        var en := Enemy.new()
        world.add_child(en)
        en.global_position = Vector2(e[0] * TILE + 16, e[1] * TILE - 24)
        en.origin_x = en.global_position.x
        en.player = player
        en.killed.connect(_on_enemy_killed)

    hud.player = player
    hud.visible = true
    controls.visible = true
    state = "play"
    _flash_message(d["name"], 2.0)


func _add_block(body: StaticBody2D, tx: int, ty: int, tw: int, th: int) -> void:
    var cs := CollisionShape2D.new()
    var sh := RectangleShape2D.new()
    sh.size = Vector2(tw * TILE, th * TILE)
    cs.shape = sh
    cs.position = Vector2(tx * TILE + tw * TILE / 2.0, ty * TILE + th * TILE / 2.0)
    body.add_child(cs)


func _add_pickup(kind: String, it: Array) -> void:
    var pk := Pickup.new()
    pk.kind = kind
    world.add_child(pk)
    pk.global_position = Vector2(it[0] * TILE + 16, it[1] * TILE - 14)


func _on_enemy_killed() -> void:
    score += 100


func _on_exit() -> void:
    if state != "play":
        return
    score += 500
    player.set_physics_process(false)
    if level_index + 1 >= Levels.LEVELS.size():
        state = "end"
        _set_message("أنجزت المهمة بنجاح!\nالنقاط: %d\n\nاضغط للعودة للقائمة" % score)
    else:
        state = "win"
        _set_message("نجحت المرحلة!\nالنقاط: %d\n\nاضغط للمتابعة" % score)


func _on_player_died() -> void:
    if state != "play":
        return
    lives -= 1
    if lives <= 0:
        state = "gameover"
        _set_message("انتهت اللعبة\nالنقاط: %d\n\nاضغط للعودة للقائمة" % score)
    else:
        state = "dead"
        _set_message("قُتلت!\nالمحاولات المتبقية: %d\n\nاضغط للمحاولة مرة أخرى" % lives)
