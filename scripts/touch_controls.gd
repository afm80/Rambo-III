extends CanvasLayer
# أزرار اللمس: يسار، يمين، قفز، إطلاق، تبديل السلاح

var left: bool = false
var right: bool = false
var jump: bool = false
var fire: bool = false
var switch_requested: bool = false

var _touches: Dictionary = {}
var _pad: Control


func _ready() -> void:
    layer = 10
    _pad = Control.new()
    _pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_pad)
    _pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _pad.draw.connect(_draw_pad)
    get_viewport().size_changed.connect(_pad.queue_redraw)


func _buttons() -> Dictionary:
    var vs: Vector2 = get_viewport().get_visible_rect().size
    return {
        "left": [Vector2(80.0, vs.y - 80.0), 48.0],
        "right": [Vector2(200.0, vs.y - 80.0), 48.0],
        "jump": [Vector2(vs.x - 80.0, vs.y - 80.0), 50.0],
        "fire": [Vector2(vs.x - 200.0, vs.y - 80.0), 54.0],
        "switch": [Vector2(vs.x - 80.0, vs.y - 190.0), 34.0],
    }


func _hit(pos: Vector2) -> String:
    var best: String = ""
    var best_d: float = 1000000.0
    var btns: Dictionary = _buttons()
    for bname in btns.keys():
        var c: Vector2 = btns[bname][0]
        var r: float = btns[bname][1]
        var d: float = pos.distance_to(c)
        if d <= r * 1.3 and d < best_d:
            best_d = d
            best = bname
    return best


func _input(event: InputEvent) -> void:
    if not visible:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            var n: String = _hit(event.position)
            _touches[event.index] = n
            if n == "switch":
                switch_requested = true
        else:
            _touches.erase(event.index)
        _update()
    elif event is InputEventScreenDrag:
        _touches[event.index] = _hit(event.position)
        _update()


func _update() -> void:
    left = false
    right = false
    jump = false
    fire = false
    for n in _touches.values():
        if n == "left":
            left = true
        elif n == "right":
            right = true
        elif n == "jump":
            jump = true
        elif n == "fire":
            fire = true
    _pad.queue_redraw()


func _is_down(bname: String) -> bool:
    return _touches.values().has(bname)


func _draw_pad() -> void:
    var btns: Dictionary = _buttons()
    for bname in btns.keys():
        var c: Vector2 = btns[bname][0]
        var r: float = btns[bname][1]
        var down: bool = _is_down(bname)
        draw_circle(c, r, Color(1, 1, 1, 0.38 if down else 0.18))
        draw_arc(c, r, 0.0, TAU, 32, Color(1, 1, 1, 0.55), 2.0)
        var s: float = r * 0.4
        var w := Color(1, 1, 1, 0.85)
        if bname == "left":
            draw_colored_polygon(PackedVector2Array([c + Vector2(-s, 0), c + Vector2(s, -s), c + Vector2(s, s)]), w)
        elif bname == "right":
            draw_colored_polygon(PackedVector2Array([c + Vector2(s, 0), c + Vector2(-s, -s), c + Vector2(-s, s)]), w)
        elif bname == "jump":
            draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(-s, s), c + Vector2(s, s)]), w)
        elif bname == "fire":
            draw_circle(c, s, Color(1, 0.35, 0.25, 0.9))
        else:
            draw_circle(c + Vector2(-8, 0), 3.0, w)
            draw_circle(c, 3.0, w)
            draw_circle(c + Vector2(8, 0), 3.0, w)
