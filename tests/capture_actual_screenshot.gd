extends SceneTree

func _initialize() -> void:
	var dir := DirAccess.open("res://")
	if dir != null:
		dir.make_dir_recursive("docs/screenshots")

	var viewport := SubViewport.new()
	viewport.size = Vector2(640, 360)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var scene := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	viewport.add_child(scene)

	for i in 8:
		await process_frame

	var texture := viewport.get_texture()
	if texture == null:
		printerr("Viewport texture is null.")
		quit(1)
		return

	var image: Image = texture.get_image()
	var err: Error = image.save_png("res://docs/screenshots/actual_game.png")
	if err != OK:
		printerr("Failed to save screenshot: %s" % err)
		quit(1)
		return

	print("Saved actual screenshot to res://docs/screenshots/actual_game.png")
	quit(0)
