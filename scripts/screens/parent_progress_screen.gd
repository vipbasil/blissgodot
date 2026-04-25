extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)

@onready var title_label: Label = %TitleLabel
@onready var sessions_value_label: Label = %SessionsValueLabel
@onready var symbols_value_label: Label = %SymbolsValueLabel
@onready var categories_value_label: Label = %CategoriesValueLabel
@onready var category_rows: VBoxContainer = %CategoryRows
@onready var back_button: Button = %BackButton


func _ready() -> void:
    back_button.pressed.connect(_on_back_pressed)
    _render()


func _render() -> void:
    var summary: Dictionary = AppState.get_parent_progress_summary()
    title_label.text = "Parent Progress"
    sessions_value_label.text = "%d" % AppState.get_completed_session_count()
    symbols_value_label.text = "%d" % int(summary.get("symbols_learned", 0))
    categories_value_label.text = "%d" % int(summary.get("categories_mastered", 0))
    _render_categories()


func _on_back_pressed() -> void:
    navigate_requested.emit("home", {})


func _render_categories() -> void:
    for child in category_rows.get_children():
        child.queue_free()

    var rows: Array[Dictionary] = AppState.get_category_progress_rows()
    for row in rows:
        var panel := PanelContainer.new()
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var style := StyleBoxFlat.new()
        style.bg_color = Color(1.0, 0.996, 0.984, 1.0)
        style.border_width_left = 1
        style.border_width_top = 1
        style.border_width_right = 1
        style.border_width_bottom = 1
        style.border_color = Color(0.84, 0.85, 0.83, 1.0)
        style.corner_radius_top_left = 18
        style.corner_radius_top_right = 18
        style.corner_radius_bottom_right = 18
        style.corner_radius_bottom_left = 18
        panel.add_theme_stylebox_override("panel", style)

        var margin := MarginContainer.new()
        margin.add_theme_constant_override("margin_left", 16)
        margin.add_theme_constant_override("margin_top", 12)
        margin.add_theme_constant_override("margin_right", 16)
        margin.add_theme_constant_override("margin_bottom", 12)
        panel.add_child(margin)

        var line := HBoxContainer.new()
        line.alignment = BoxContainer.ALIGNMENT_CENTER
        margin.add_child(line)

        var name_label := Label.new()
        name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        name_label.text = String(row.get("display_name", "Category"))
        name_label.add_theme_font_size_override("font_size", 20)
        line.add_child(name_label)

        var count_label := Label.new()
        count_label.text = "%d / %d" % [int(row.get("learned_count", 0)), int(row.get("total_count", 0))]
        count_label.add_theme_font_size_override("font_size", 18)
        line.add_child(count_label)

        var state_label := Label.new()
        state_label.text = "Mastered" if bool(row.get("mastered", false)) else "In progress"
        state_label.add_theme_font_size_override("font_size", 18)
        if bool(row.get("mastered", false)):
            state_label.modulate = Color(0.33, 0.56, 0.42, 1.0)
        else:
            state_label.modulate = Color(0.44, 0.46, 0.48, 1.0)
        line.add_child(state_label)

        category_rows.add_child(panel)
