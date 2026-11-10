extends Control
# شريط الصحة والأسلحة والذخيرة والأرواح والنقاط (أرقام ورموز فقط)

var player = null
var lives: int = 3
var score: int = 0


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    if player == null or not is_instance_valid(player):
        return
    var f: Font = ThemeDB.fallback_font
    var vs: Vector2 = get_viewport().get_visible_rect().size

    # الصحة
    draw_rect(Rect2(16, 14, 204, 18), Color(0, 0, 0, 0.55))
    var w: float = 200.0 * clampf(float(player.hp) / 100.0, 0.0, 1.0)
    draw_rect(Rect2(18, 16, w, 14), Color(0.85, 0.15, 0.15))

    # الأسلحة
    for i in range(3):
        var x: float = 16.0 + float(i) * 66.0
        var sel: bool = player.weapon == i
        draw_rect(Rect2(x, 40, 60, 36), Color(1, 1, 1, 0.3 if sel else 0.1))
        var cx: float = x + 18.0
        if i == 0:
            draw_line(Vector2(cx - 8, 66), Vector2(cx + 8, 48), Color(0.9, 0.9, 0.95), 3.0)
        elif i == 1:
            draw_arc(Vector2(cx - 2, 58), 10.0, -PI / 2.0, PI / 2.0, 10, Color(0.8, 0.55, 0.25), 3.0)
            draw_line(Vector2(cx - 2, 48), Vector2(cx - 2, 68), Color(1, 1, 1), 1.0)
        else:
            draw_line(Vector2(cx - 10, 58), Vector2(cx + 10, 58), Color(0.85, 0.85, 0.85), 5.0)
            draw_rect(Rect2(cx - 10, 58, 6, 8), Color(0.85, 0.85, 0.85))
        var txt: String = "--"
        if i == 1:
            txt = str(player.arrows)
        elif i == 2:
            txt = str(player.bullets)
        draw_string(f, Vector2(x + 32.0, 66.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(1, 1, 1))

    # الأرواح
    for i in range(lives):
        var px: float = vs.x - 24.0 - float(i) * 26.0
        draw_circle(Vector2(px, 24), 9.0, Color(0.88, 0.62, 0.42))
        draw_rect(Rect2(px - 9.0, 17, 18, 4), Color(0.85, 0.1, 0.1))

    # النقاط
    draw_string(f, Vector2(0, 28), str(score), HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color(1, 1, 1))
