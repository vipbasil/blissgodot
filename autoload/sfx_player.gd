extends Node

const SUCCESS_PATH := "res://assets/audio/sfx/success.wav"
const SUMMARY_PATH := "res://assets/audio/sfx/summary.wav"

var success_player: AudioStreamPlayer
var summary_player: AudioStreamPlayer


func _ready() -> void:
    success_player = _build_player("success_player", _load_stream(SUCCESS_PATH))
    summary_player = _build_player("summary_player", _load_stream(SUMMARY_PATH))


func play_success() -> void:
    _play_player(success_player)


func play_summary() -> void:
    _play_player(summary_player)


func _build_player(player_name: String, stream: AudioStream) -> AudioStreamPlayer:
    var player := AudioStreamPlayer.new()
    player.name = player_name
    player.stream = stream
    player.bus = "Master"
    add_child(player)
    return player


func _load_stream(path: String) -> AudioStream:
    if not ResourceLoader.exists(path):
        return null
    return load(path) as AudioStream


func _play_player(player: AudioStreamPlayer) -> void:
    if player == null or player.stream == null:
        return
    if not AppState.is_sfx_enabled():
        return

    player.stop()
    player.play()
