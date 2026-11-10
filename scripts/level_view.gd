extends Node2D
# رسم خلفية المرحلة والأرض والمنصات

const TILE: int = 32

var ground: Array = []
var platforms: Array = []
var width_px: float = 0.0
var theme: String = "jungle"


func setup(g: Array, p: Array, w: float, th: String) -> void:
    ground = g
    platforms = p
    width_px = w
    theme = th
    queue_redraw()


func _draw() -> void:
    var hill := Color(0.35, 0.6, 0.4)
    var top := Color(0.25, 0.6, 0.2)
    var body := Color(0.45, 0.3, 0.16)
    var plank := Color(0.55, 0.38, 0.2)
    if theme == "fort":
        hill = Color(0.6, 0.4, 0.35)
        top = Color(0.5, 0.5, 0.52)
        body = Color(0.36, 0.36, 0.4)
        plank = Color(0.45, 0.42, 0.42)

    # تلال بعيدة
    var n: int = int(width_px / 300.0) + 1
    for i in range(n):
        draw_circle(Vector2(float(i) * 300.0 + 150.0, 520.0), 170.0, hill)

    # أشجار / أعمدة خلف الأرض
    for g in ground:
        var gx0: int = g[0]
        var gx1: int = g[1]
        var gy: int = g[2]
        var tx: int = gx0 + 2
        while tx < gx1 - 1:
            var px: float = float(tx * TILE + 16)
            var py: float = float(gy * TILE)
            if theme == "fort":
                draw_rect(Rect2(px - 6, py - 70, 12, 70), Color(0.3, 0.3, 0.34))
                draw_rect(Rect2(px - 10, py - 78, 20, 10), Color(0.38, 0.38, 0.42))
            else:
                draw_rect(Rect2(px - 5, py - 60, 10, 60), Color(0.4, 0.26, 0.12))
                draw_circle(Vector2(px, py - 70), 26.0, Color(0.15, 0.45, 0.18))
                draw_circle(Vector2(px - 16, py - 56), 18.0, Color(0.18, 0.5, 0.2))
                draw_circle(Vector2(px + 16, py - 56), 18.0, Color(0.18, 0.5, 0.2))
            tx += 6

    # الأرض
    for g in ground:
        var x: float = float(g[0] * TILE)
        var y: float = float(g[2] * TILE)
        var w: float = float((g[1] - g[0]) * TILE)
        var h: float = float((18 - g[2]) * TILE)
        draw_rect(Rect2(x, y, w, h), body)
        draw_rect(Rect2(x, y, w, 8.0), top)

    # المنصات
    for p in platforms:
        var x2: float = float(p[0] * TILE)
        var y2: float = float(p[2] * TILE)
        var w2: float = float((p[1] - p[0]) * TILE)
        draw_rect(Rect2(x2, y2, w2, float(TILE)), plank)
        draw_rect(Rect2(x2, y2, w2, 6.0), top)
