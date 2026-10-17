extends CanvasLayer

const HEART_FULL: Texture2D = preload("res://assets/ui/heart_full.png")
const HEART_EMPTY: Texture2D = preload("res://assets/ui/heart_empty.png")

## Cantidad de corazones que se muestran (cada uno vale max_health / heart_count).
@export var heart_count: int = 10

@onready var health_panel: PanelContainer = $HUDContainer/HealthPanel
@onready var hearts_container: HBoxContainer = $HUDContainer/HealthPanel/HeartsContainer
@onready var crystal_label: Label = $HUDContainer/CrystalsPanel/HBoxContainer/CrystalLabel
@onready var quest_label: Label = $HUDContainer/QuestPanel/QuestLabel

var hearts: Array[TextureRect] = []
var last_health: int = -1


func _ready() -> void:
	_build_hearts()
	QuestManager.quest_updated.connect(update_quest_info)
	update_quest_info()


func _build_hearts() -> void:
	for child in hearts_container.get_children():
		child.queue_free()
	hearts.clear()

	for i in heart_count:
		var heart := TextureRect.new()
		heart.texture = HEART_FULL
		heart.custom_minimum_size = Vector2(29, 26)
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hearts_container.add_child(heart)
		hearts.append(heart)


func update_health(current: int, max: int) -> void:
	if hearts.is_empty():
		return

	var hp_per_heart: float = float(max) / float(heart_count)
	for i in hearts.size():
		# Un corazón está lleno mientras la vida supere el tramo anterior.
		var is_full: bool = float(current) > hp_per_heart * i
		hearts[i].texture = HEART_FULL if is_full else HEART_EMPTY

	# Destello rojo cuando el jugador recibe daño.
	if last_health != -1 and current < last_health:
		health_panel.modulate = Color(1.0, 0.45, 0.45)
		var tween := create_tween()
		tween.tween_property(health_panel, "modulate", Color.WHITE, 0.35)
	last_health = current


func update_quest_info() -> void:
	crystal_label.text = "%d/%d" % [
		QuestManager.collected_crystals,
		QuestManager.required_crystals
	]
	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			quest_label.text = "MISION: Habla con Han Solo"
		QuestManager.QuestState.ACTIVE:
			quest_label.text = "MISION: Recolecta los cristales"
		QuestManager.QuestState.READY_TO_DELIVER:
			quest_label.text = "MISION: Entrega los cristales a Han Solo"
		QuestManager.QuestState.COMPLETED:
			quest_label.text = "MISION COMPLETADA"
