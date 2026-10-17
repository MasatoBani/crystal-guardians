extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var dialogue_label: Label = $PanelContainer/VBoxContainer/MarginContainer/DialogueLabel
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton

var current_dialogues: Array[String] = []
var dialogue_index: int = 0
var is_open: bool = false

func _ready() -> void:
	panel.hide()
	continue_button.pressed.connect(next_dialogue)
	panel.gui_input.connect(_on_panel_gui_input)

func _on_panel_gui_input(event: InputEvent) -> void:
	# Tocar el panel (o clic) avanza el diálogo; útil en móvil.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		next_dialogue()
		panel.accept_event()

func show_dialogue(character_name: String, dialogues: Array[String]) -> void:
	if dialogues.is_empty():
		return
	current_dialogues = dialogues
	dialogue_index = 0
	is_open = true
	name_label.text = character_name
	dialogue_label.text = dialogues[0]
	panel.show()
func next_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index >= current_dialogues.size():
		close_dialogue()
		return
	dialogue_label.text = current_dialogues[dialogue_index]
func close_dialogue() -> void:
	panel.hide()
	is_open = false
