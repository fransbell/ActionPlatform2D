extends Node

static func get_tilemapRect(tilemap_cell,tile_pos:Vector2,cell_size,scale):
	#initialzie variable
	var used_cells = tilemap_cell
	var _max = Vector2.ZERO	
	var _min = Vector2.ZERO
	#asiign & calculate cell_size
	var _size = cell_size
	var _scale = scale
	var format = _size * _scale
	#calculate bound
	for pos in used_cells:
		if pos.x < _min.x:
			_min.x = int(pos.x)
		elif pos.x > _max.x:
			_max.x = int(pos.x)
		if pos.y < _min.y:
			_min.y = int(pos.y)
		elif pos.y > _max.y:
			_max.y = int(pos.y)
	#calculate global position
	_min = (_min * format) + tile_pos
	_max = ((_max * format) + format) + tile_pos
	
	return [_min,_max]

static func get_is_inRoom(player_pos,bound,is_player_inRoom,camera):
	var tmp = {
		"top":bound[0].y,
		"left":bound[0].x,
		"bottom":bound[1].y,
		"right":bound[1].x
	}
	
	if is_player_inRoom :
		if player_pos.x < (tmp.left + 400):
			camera.move_to("position:x",camera.position.x,tmp.left + 400,0.12)
		elif player_pos.x > (tmp.right - 400):
			camera.move_to("position:x",camera.position.x,tmp.right - 400,0.12)
		else:
			camera.move_to("position:x",camera.position.x,player_pos.x,0.2)
		
		if (tmp.top+tmp.bottom) == 320:
			camera.move_to("position:y",camera.position.y,tmp.top + 224,0.12)
			camera.zoom = Vector2(0.996,0.996)
		elif player_pos.y > tmp.bottom - 225:
			camera.move_to("position:y",camera.position.y,tmp.bottom - 225,0.12)
		elif player_pos.y < tmp.top + 225:
			camera.move_to("position:y",camera.position.y,tmp.top + 225,0.12)
		else:
			camera.move_to("position:y",camera.position.y,player_pos.y,0.2)
			
#	if is_player_inRoom:
#		if player_pos.x < tmp.left or player_pos.x > tmp.right or player_pos.y < tmp.top or player_pos.y > tmp.bottom:
#			is_player_inRoom = false
#	if !is_player_inRoom:
#		if player_pos.x > tmp.left and player_pos.x < tmp.right and player_pos.y > tmp.top and player_pos.y < tmp.bottom:
#			is_player_inRoom = true
