extends HBoxContainer

var total := 0
var current := 0


func set_total(value: int) -> void:
    total = value
    _render()


func set_current(value: int) -> void:
    current = value
    _render()


func _render() -> void:
    for child in get_children():
        child.queue_free()

    for index in total:
        var dot := ColorRect.new()
        dot.custom_minimum_size = Vector2(18, 18)
        dot.color = Color(0.81, 0.84, 0.89, 1.0)
        if index < current:
            dot.color = Color(0.47, 0.71, 0.53, 1.0)
        add_child(dot)
