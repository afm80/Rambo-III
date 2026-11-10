extends Area2D
# رصاصة / سهم. kind: 1 = سهم، 2 = رصاصة اللاعب، 3 = رصاصة العدو

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var kind: int = 2
var from_player: bool = true
var life: float = 2.0


func setup(k: int, v: Vector2, dmg: int, fp: bool) -> void:
    kind = k
    velocity = v
    damage = dmg
    from_player = fp


func _ready() -> void:
    if from_player:
        collision_layer = 8
        collision_mask = 1 | 4
    else:
        collision_layer = 16
        collision_mask = 1 | 2
    var cs := CollisionShape2D.new()
    var sh := CircleShape2D.new()
    sh.radius = 5.0
    cs.shape = sh
    add_child(cs)
    body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
    position += velocity * delta
    life -= delta
    if life <= 0.0:
        queue_free()


func _on_body_entered(body: Node) -> void:
    if body.has_method("hurt"):
        body.hurt(damage)
    queue_free()


func _draw() -> void:
    var d: float = signf(velocity.x)
    if d == 0.0:
        d = 1.0
    if kind == 1:
        draw_line(Vector2(-14.0 * d, 0), Vector2(8.0 * d, 0), Color(0.55, 0.35, 0.15), 2.0)
        draw_colored_polygon(PackedVector2Array([Vector2(8.0 * d, -4), Vector2(15.0 * d, 0), Vector2(8.0 * d, 4)]), Color(0.85, 0.85, 0.85))
    elif kind == 2:
        draw_line(Vector2(-6.0 * d, 0), Vector2(4.0 * d, 0), Color(1.0, 0.9, 0.3), 3.0)
    else:
        draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.4, 0.2))
