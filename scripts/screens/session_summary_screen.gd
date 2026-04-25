extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)

@onready var title_label: Label = %TitleLabel
@onready var stars_label: Label = %StarsLabel
@onready var praise_label: Label = %PraiseLabel
@onready var detail_label: Label = %DetailLabel
@onready var continue_button: Button = %ContinueButton

var results: Array[Dictionary] = []
var node_id := ""


func initialize(payload: Dictionary) -> void:
    node_id = String(payload.get("node_id", ""))
    results = payload.get("results", [])


func _ready() -> void:
    continue_button.pressed.connect(_on_continue_pressed)
    _render_summary()


func _render_summary() -> void:
    var supported_count: int = 0
    for result in results:
        if String(result.get("outcome", "")) == "supported_success":
            supported_count += 1

    var stars: int = 1
    if supported_count <= 1:
        stars = 3
    elif supported_count <= 3:
        stars = 2

    title_label.text = "Session Complete"
    stars_label.text = _build_star_string(stars)
    praise_label.text = _build_praise_text(stars)
    detail_label.text = "%d rounds complete" % results.size()
    SfxPlayer.play_summary()


func _on_continue_pressed() -> void:
    navigate_requested.emit("summary_continue", {
        "node_id": node_id,
    })


func _build_star_string(stars: int) -> String:
    var out := ""
    for index in 3:
        if index < stars:
            out += "★"
        else:
            out += "☆"
        if index < 2:
            out += " "
    return out


func _build_praise_text(stars: int) -> String:
    if stars == 3:
        return "Calm, confident work"
    if stars == 2:
        return "Nice steady practice"
    return "Good session"
