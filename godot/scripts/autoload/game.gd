extends Node
## Uygulama durumu: içerik, ilerleme ve ekranlar arası geçiş.

var content: Content
var progress: Progress
## Açılacak ekrana verilen parametreler.
var params := {}


func _ready() -> void:
	content = Content.load_all()
	for e in content.errors:
		push_error(e)
	progress = Progress.new(content)
	progress.load_save()


func goto(scene: String, p_params := {}) -> void:
	params = p_params
	get_tree().change_scene_to_file("res://scenes/%s.tscn" % scene)
