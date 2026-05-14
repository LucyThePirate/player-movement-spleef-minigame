extends Node2D

@export var ice_block_scene : PackedScene

@onready var glass_tile = [1, Vector2i(2, 0)]
@onready var ice_tile = [1, Vector2i(2, 1)]
var living_players = [1, 2]

func _ready() -> void:
	# This is just to save headaches where I try moving characters only to realize I was actually typing "awdsawasda" in a code window.
	get_window().grab_focus()
	%GetReadySFX.play()
	for tile in %Tiles.get_used_cells_by_id(ice_tile[0], ice_tile[1]):
		%Tiles.set_cell(tile, -1)
		var new_ice_block = ice_block_scene.instantiate()
		new_ice_block.position = %Tiles.map_to_local(tile)
		%Tiles.add_child(new_ice_block)


func _on_start_timer_timeout() -> void:
	%Label.text = "[shake]\nGO!!!"
	%GoSFX.play()
	%HideGoTextTimer.start()
	for tile in %Tiles.get_used_cells_by_id(glass_tile[0], glass_tile[1]):
		%Tiles.set_cell(tile, -1)


func _on_hide_go_text_timer_timeout() -> void:
	%Label.text = ""


func _on_lava_body_entered(body: Node2D) -> void:
	if body is SpleefPlayer:
		living_players.erase(body.player_num)
		body._on_fallen_out_of_bounds()
		if living_players.size() == 1:
			_game_over()
	elif body is SpleefProjectile:
		body._on_fallen_out_of_bounds()
			

func _game_over():
	%GoSFX.pitch_scale = 1.5
	%GoSFX.play()
	%HideGoTextTimer.stop()
	%Label.text = "[wave][rainbow freq=0.2]\nPlayer %s wins!\n" % living_players[0]
	%RestartGameTimer.start()


func _on_restart_game_timer_timeout() -> void:
	get_tree().reload_current_scene()
