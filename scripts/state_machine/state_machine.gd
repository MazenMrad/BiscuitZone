class_name StateMachine
extends Node

@export var initial_state: State
@export var player: Character

var current_state: State
var states: Dictionary[String, State] = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
			child.player = player
			states[child.name.to_lower()] = child

	if initial_state:
		initial_state.enter()
		current_state = initial_state


func _physics_process(delta):
	current_state.update(delta)
