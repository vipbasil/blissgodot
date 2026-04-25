extends Control

@onready var label: Label = %FeedbackLabel


func show_success() -> void:
    label.text = "Good"
    modulate = Color(1, 1, 1, 0)
    visible = true
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)
    tween.tween_interval(0.22)
    tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.18)
    tween.tween_callback(hide_feedback)


func hide_feedback() -> void:
    visible = false
