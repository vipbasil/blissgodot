class_name ConceptRecord
extends RefCounted

var id: String
var category_id: String
var release_phase: int
var progression_band_start: String
var default_puzzle_types: Array[String]
var symbol_asset: String
var picture_asset: String
var enabled: bool


static func from_dict(data: Dictionary) -> ConceptRecord:
    var record := ConceptRecord.new()
    record.id = String(data.get("id", ""))
    record.category_id = String(data.get("category_id", ""))
    record.release_phase = int(data.get("release_phase", 0))
    record.progression_band_start = String(data.get("progression_band_start", "band_a"))
    record.default_puzzle_types = []
    for value in data.get("default_puzzle_types", []):
        record.default_puzzle_types.append(String(value))
    record.symbol_asset = String(data.get("symbol_asset", ""))
    record.picture_asset = String(data.get("picture_asset", ""))
    record.enabled = bool(data.get("enabled", true))
    return record
