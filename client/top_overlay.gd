class_name ClientTopOverlay extends CanvasLayer

@onready var is_displayed: bool = false
@onready var background_panel: Panel = $DisconnectPanel
@onready var title_label: Label = $DisconnectPanel/VBoxContainer/Title
@onready var content_label: Label = $DisconnectPanel/VBoxContainer/Content

func set_overlay_message(
	message_title: String = "",
	message_content: String = ""
) -> void:
	title_label.text = message_title
	content_label.text = message_content

func display() -> void:
	background_panel.visible = true
	background_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(background_panel, "modulate:a", 1.0, .5)
	is_displayed = true

func display_not() -> void:
	# Lol idk what to say
	# I mean I wont even be using a reverse display soon anywayss
	var tween := create_tween()
	background_panel.modulate.a = 1.0
	tween.tween_property(background_panel, "modulate:a", 0.0, .5)
	tween.finished.connect(
		func() -> void:
			background_panel.visible = false
	)
	is_displayed = false
