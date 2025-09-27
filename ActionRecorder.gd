extends Node

var history: Array = []

const MAX_HISTORY_SECONDS = 6

func record_state(player_state: Dictionary):
	player_state["timestamp"] = Time.get_ticks_msec()
	history.append(player_state)

	var oldest_allowed = Time.get_ticks_msec() - (MAX_HISTORY_SECONDS * 1000)
	while not history.is_empty() and history.front()["timestamp"] < oldest_allowed:
		history.pop_front()

func reset():
	history.clear()
