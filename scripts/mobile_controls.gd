extends CanvasLayer
## Controles táctiles: joystick virtual (movimiento) + botones de ataque e interacción.
##
## - El joystick dispara las acciones "move_left/right/up/down" con fuerza analógica,
##   así player.gd (Input.get_vector) funciona igual que con el teclado.
## - Los TouchScreenButton disparan "player_attack" e "interact" mediante su
##   propiedad `action`; no necesitan código adicional.

@onready var joystick_base: Control = $Controls/JoystickBase
@onready var joystick_knob: Control = $Controls/JoystickBase/JoystickKnob

@export var joystick_radius: float = 65.0
@export var deadzone: float = 0.15
## Margen extra (en píxeles) alrededor de la base donde se acepta el toque.
@export var touch_margin: float = 40.0
## Mostrar los controles también en PC (útil para probar con el mouse).
@export var show_on_desktop: bool = true

var joystick_direction: Vector2 = Vector2.ZERO
var active_touch_index: int = -1


func _ready() -> void:
	var is_touch_device := (
		DisplayServer.is_touchscreen_available()
		or OS.has_feature("mobile")
		or OS.has_feature("web")
	)
	visible = is_touch_device or show_on_desktop
	# Esperamos al layout para centrar el knob con el tamaño real de la base.
	call_deferred("reset_joystick")


func _exit_tree() -> void:
	_release_move_actions()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			if active_touch_index == -1 and is_inside_joystick(event.position):
				active_touch_index = event.index
				update_joystick(event.position)
				get_viewport().set_input_as_handled()
		elif event.index == active_touch_index:
			active_touch_index = -1
			reset_joystick()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if event.index == active_touch_index:
			update_joystick(event.position)
			get_viewport().set_input_as_handled()


func _joystick_center() -> Vector2:
	return joystick_base.global_position + joystick_base.size / 2.0


func is_inside_joystick(screen_position: Vector2) -> bool:
	var reach := joystick_base.size.x / 2.0 + touch_margin
	return screen_position.distance_to(_joystick_center()) <= reach


func update_joystick(screen_position: Vector2) -> void:
	var offset := screen_position - _joystick_center()
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius

	# El knob se mueve visualmente dentro de la base.
	joystick_knob.position = (joystick_base.size - joystick_knob.size) / 2.0 + offset

	var direction := offset / joystick_radius
	if direction.length() < deadzone:
		direction = Vector2.ZERO
	joystick_direction = direction
	_apply_move_actions(direction)


func reset_joystick() -> void:
	joystick_direction = Vector2.ZERO
	joystick_knob.position = (joystick_base.size - joystick_knob.size) / 2.0
	_release_move_actions()


func _apply_move_actions(direction: Vector2) -> void:
	_set_action("move_right", maxf(direction.x, 0.0))
	_set_action("move_left", maxf(-direction.x, 0.0))
	_set_action("move_down", maxf(direction.y, 0.0))
	_set_action("move_up", maxf(-direction.y, 0.0))


func _release_move_actions() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)


func _set_action(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)
