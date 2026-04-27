extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)


func _ready() -> void:
    _bootstrap()


func _bootstrap() -> void:
    ContentDB.load_content()
    LearningStoreService.initialize()
    AppState.load_from_disk()
    await get_tree().process_frame
    navigate_requested.emit("home", {})
