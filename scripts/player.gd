extends CharacterBody2D
# اللاعب: جري، قفز، سكين / قوس / رشاش

signal died

const SPEED: float = 230.0
const JUMP_VELOCITY: float = -540.0
const GRAVITY: float = 1300.0
const MAX_HP: int = 100
const Bullet := preload("res://scripts/bullet.gd")

var controls = null
var facing: int = 1
var hp: int = MAX_HP
var weapon: int = 2          # 0 سكين، 1 قوس، 2 رشاش
var arrows: int = 8
var bullets: int = 80
var cooldown: float = 0.0
var invuln: float = 0.0
var melee_flash: float = 0.0
var alive: bool = true
var _prev_jump: bool = false
var _prev_switch: bool = false
var _walk_t: float = 0.0
var _moving: bool = false


func _ready() -> void:
    collision_layer = 2
    collision_mask = 1
    var cs := CollisionShape2D.new()
    var sh := RectangleShape2D.new()
    sh.size = Vector2(22, 44)
    cs.shape = sh
    add_child(cs)
    add_to_group("player")


func _physics_process(delta: float) -> void:
    if not alive:
        return

    var dir: float = 0.0
    if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A):
        dir -= 1.0
    if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D):
        dir += 1.0
    var jump_now: bool = Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_SPACE)
    var fire_now: bool = Input.is_physical_key_pressed(KEY_J) or Input.is_physical_key_pressed(KEY_X)
    var switch_key: bool = Input.is_physical_key_pressed(KEY_K) or Input.is_physical_key_pressed(KEY_C)

    if controls != null:
        if controls.left:
            dir -= 1.0
        if controls.right:
            dir += 1.0
        if controls.jump:
            jump_now = true
        if controls.fire:
            fire_now = true
        if controls.switch_requested:
            controls.switch_requested = false
            _cycle_weapon()
    dir = clampf(dir, -1.0, 1.0)

    if switch_key and not _prev_switch:
        _cycle_weapon()
    _prev_switch = switch_key

    # الجاذبية والقفز
    if not is_on_floor():
        velocity.y = minf(velocity.y + GRAVITY * delta, 900.0)
    elif jump_now and not _prev_jump:
        velocity.y = JUMP_VELOCITY
    _prev_jump = jump_now

    velocity.x = dir * SPEED
    _moving = dir != 0.0
    if _moving:
        facing = 1 if dir > 0.0 else -1
        _walk_t += delta * 14.0
    move_and_slide()

    # الإطلاق
    cooldown -= delta
    invuln = maxf(invuln - delta, 0.0)
    melee_flash = maxf(melee_flash - delta, 0.0)
    if fire_now and cooldown <= 0.0:
        _fire()

    # السقوط خارج العالم
    if global_position.y > 700.0:
        hp = 0
        _die()
    queue_redraw()


func _cycle_weapon() -> void:
    weapon = (weapon + 1) % 3


func _fire() -> void:
    if weapon == 0:
        cooldown = 0.35
        melee_flash = 0.15
        for e in get_tree().get_nodes_in_group("enemies"):
            var dx: float = e.global_position.x - global_position.x
            var dy: float = e.global_position.y - global_position.y
            if absf(dy) < 40.0 and dx * float(facing) > -10.0 and absf(dx) < 58.0:
                e.hurt(2)
    elif weapon == 1:
        if arrows <= 0:
            weapon = 0
            return
        arrows -= 1
        cooldown = 0.6
        _spawn_bullet(1, 560.0, 4)
    else:
        if bullets <= 0:
            weapon = 0
            return
        bullets -= 1
        cooldown = 0.12
        _spawn_bullet(2, 800.0, 1)


func _spawn_bullet(kind: int, speed: float, dmg: int) -> void:
    var b := Bullet.new()
    b.setup(kind, Vector2(float(facing) * speed, 0), dmg, true)
    get_parent().add_child(b)
    b.global_position = global_position + Vector2(float(facing) * 24.0, -3.0)


func hurt(amount: int) -> void:
    if invuln > 0.0 or not alive:
        return
    hp -= amount
    invuln = 1.0
    if hp <= 0:
        hp = 0
        _die()


func _die() -> void:
    if not alive:
        return
    alive = false
    died.emit()


func collect(kind: String) -> void:
    if kind == "health":
        hp = mini(hp + 30, MAX_HP)
    else:
        bullets += 30
        arrows += 4


func _draw() -> void:
    if not alive:
        return
    if invuln > 0.0 and int(invuln * 12.0) % 2 == 0:
        return
    var f: float = float(facing)
    var skin := Color(0.88, 0.62, 0.42)
    var pants := Color(0.18, 0.25, 0.14)
    var swing: float = 0.0
    if _moving and is_on_floor():
        swing = sin(_walk_t) * 6.0
    # الساقان والحذاء
    draw_rect(Rect2(-8 + swing, 6, 7, 16), pants)
    draw_rect(Rect2(1 - swing, 6, 7, 16), pants)
    draw_rect(Rect2(-9 + swing, 19, 9, 3), Color(0.1, 0.1, 0.1))
    draw_rect(Rect2(0 - swing, 19, 9, 3), Color(0.1, 0.1, 0.1))
    # الجذع وحزام الذخيرة
    draw_rect(Rect2(-9, -8, 18, 16), skin)
    draw_line(Vector2(-8, -7), Vector2(8, 7), Color(0.35, 0.25, 0.1), 3.0)
    # الرأس والشعر والعصابة الحمراء
    draw_circle(Vector2(0, -15), 7.0, skin)
    draw_rect(Rect2(-7, -23, 14, 4), Color(0.08, 0.06, 0.05))
    draw_rect(Rect2(-8, -20, 16, 3), Color(0.85, 0.1, 0.1))
    draw_line(Vector2(-f * 7.0, -18), Vector2(-f * 15.0, -13), Color(0.85, 0.1, 0.1), 2.0)
    # الذراع والسلاح
    draw_line(Vector2(f * 2.0, -4), Vector2(f * 10.0, -2), skin, 4.0)
    if weapon == 2:
        draw_line(Vector2(f * 6.0, -2), Vector2(f * 26.0, -2), Color(0.12, 0.12, 0.12), 5.0)
    elif weapon == 1:
        var a0: float = -PI / 2.0
        var a1: float = PI / 2.0
        if facing < 0:
            a0 = PI / 2.0
            a1 = PI * 1.5
        draw_arc(Vector2(f * 14.0, -2), 14.0, a0, a1, 12, Color(0.5, 0.3, 0.12), 3.0)
        draw_line(Vector2(f * 14.0, -16), Vector2(f * 14.0, 12), Color(0.9, 0.9, 0.9), 1.0)
    else:
        draw_line(Vector2(f * 10.0, -2), Vector2(f * 22.0, -4), Color(0.85, 0.85, 0.9), 3.0)
        if melee_flash > 0.0:
            draw_line(Vector2(f * 12.0, -16), Vector2(f * 40.0, 8), Color(1, 1, 1, 0.85), 4.0)
