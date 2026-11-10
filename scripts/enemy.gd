extends CharacterBody2D
# جندي عدو: يتجول ويطلق النار عند رؤية اللاعب

signal killed

const GRAVITY: float = 1300.0
const Bullet := preload("res://scripts/bullet.gd")

var hp: int = 3
var dir: int = 1
var origin_x: float = 0.0
var patrol: float = 90.0
var shoot_cd: float = 1.2
var player = null
var hit_flash: float = 0.0
var muzzle: float = 0.0
var _walk_t: float = 0.0


func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    var cs := CollisionShape2D.new()
    var sh := RectangleShape2D.new()
    sh.size = Vector2(24, 44)
    cs.shape = sh
    add_child(cs)
    add_to_group("enemies")
    dir = 1 if randf() > 0.5 else -1
    shoot_cd = 0.8 + randf()


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y = minf(velocity.y + GRAVITY * delta, 900.0)
    else:
        velocity.y = 0.0
    hit_flash = maxf(hit_flash - delta, 0.0)
    muzzle = maxf(muzzle - delta, 0.0)

    var sees: bool = false
    if player != null and is_instance_valid(player) and player.alive:
        var dx: float = player.global_position.x - global_position.x
        var dy: float = player.global_position.y - global_position.y
        if absf(dx) < 420.0 and absf(dy) < 90.0:
            sees = true
            dir = 1 if dx > 0.0 else -1
    if sees:
        velocity.x = 0.0
        shoot_cd -= delta
        if shoot_cd <= 0.0:
            shoot_cd = 1.3 + randf() * 0.6
            _shoot()
    else:
        velocity.x = float(dir) * 60.0
        _walk_t += delta * 8.0
        if absf(global_position.x - origin_x) > patrol or is_on_wall():
            dir = -dir
    move_and_slide()
    queue_redraw()


func _shoot() -> void:
    muzzle = 0.1
    var b := Bullet.new()
    b.setup(3, Vector2(float(dir) * 320.0, 0), 12, false)
    get_parent().add_child(b)
    b.global_position = global_position + Vector2(float(dir) * 24.0, -4.0)


func hurt(amount: int) -> void:
    hp -= amount
    hit_flash = 0.1
    if hp <= 0:
        killed.emit()
        queue_free()


func _draw() -> void:
    var f: float = float(dir)
    var cloth := Color(0.55, 0.5, 0.3)
    if hit_flash > 0.0:
        cloth = Color(1, 1, 1)
    var swing: float = sin(_walk_t) * 5.0
    draw_rect(Rect2(-8 + swing, 6, 7, 16), Color(0.4, 0.37, 0.22))
    draw_rect(Rect2(1 - swing, 6, 7, 16), Color(0.4, 0.37, 0.22))
    draw_rect(Rect2(-9, -8, 18, 16), cloth)
    draw_circle(Vector2(0, -15), 7.0, Color(0.85, 0.65, 0.5))
    # خوذة
    draw_rect(Rect2(-8, -24, 16, 7), Color(0.3, 0.34, 0.2))
    # بندقية
    draw_line(Vector2(f * 2.0, -2), Vector2(f * 24.0, -2), Color(0.12, 0.12, 0.12), 4.0)
    if muzzle > 0.0:
        draw_circle(Vector2(f * 28.0, -2), 5.0, Color(1.0, 0.85, 0.3))
