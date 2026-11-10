extends Area2D
# صندوق ذخيرة أو صحة. kind: "ammo" أو "health"

var kind: String = "ammo"
var _t: float = 0.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var cs := CollisionShape2D.new()
    var sh := RectangleShape2D.new()
    sh.size = Vector2(26, 26)
    cs.shape = sh
    add_child(cs)
    body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
    _t += delta
    queue_redraw()


func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        body.collect(kind)
        queue_free()


func _draw() -> void:
    var bob: float = sin(_t * 4.0) * 2.0
    if kind == "health":
        draw_rect(Rect2(-12, -12 + bob, 24, 24), Color(0.95, 0.95, 0.95))
        draw_rect(Rect2(-3, -9 + bob, 6, 18), Color(0.85, 0.1, 0.1))
        draw_rect(Rect2(-9, -3 + bob, 18, 6), Color(0.85, 0.1, 0.1))
    else:
        draw_rect(Rect2(-12, -10 + bob, 24, 20), Color(0.3, 0.38, 0.2))
        draw_rect(Rect2(-12, -10 + bob, 24, 4), Color(0.2, 0.26, 0.14))
        draw_rect(Rect2(-7, -3 + bob, 3, 9), Color(1.0, 0.85, 0.3))
        draw_rect(Rect2(-1, -3 + bob, 3, 9), Color(1.0, 0.85, 0.3))
        draw_rect(Rect2(5, -3 + bob, 3, 9), Color(1.0, 0.85, 0.3))
