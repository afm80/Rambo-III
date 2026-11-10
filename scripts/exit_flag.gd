extends Area2D
# علم نهاية المرحلة

signal reached

var _t: float = 0.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var cs := CollisionShape2D.new()
    var sh := RectangleShape2D.new()
    sh.size = Vector2(32, 64)
    cs.shape = sh
    add_child(cs)
    body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
    _t += delta
    queue_redraw()


func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        reached.emit()


func _draw() -> void:
    draw_rect(Rect2(-2, -32, 4, 64), Color(0.8, 0.8, 0.8))
    var w: float = sin(_t * 5.0) * 3.0
    draw_colored_polygon(PackedVector2Array([Vector2(2, -30), Vector2(30, -24 + w), Vector2(2, -14)]), Color(0.9, 0.15, 0.15))
