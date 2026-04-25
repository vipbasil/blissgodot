extends HBoxContainer


func add_choice(card: Control) -> void:
    add_child(card)


func clear_choices() -> void:
    for child in get_children():
        child.queue_free()
