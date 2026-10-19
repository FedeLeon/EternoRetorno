extends RefCounted
## Read-only stock and reward receipts. Transactions remain in rules/Game.
const ART = "res://assets/forge/materials/"

static func icon(ui: Control, kind: String, area: Rect2, parent: Control) -> void:
	var picture = TextureRect.new()
	picture.texture = load(ART + kind + ".png")
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(picture, area.position.x, area.position.y, area.size.x, area.size.y, parent)

static func stock(ui: Control, model: Dictionary, smelt: Callable) -> void:
	var panel = ui.panel(28, 532, 570, 174)
	panel.name = "ForgeMaterials"
	ui.label_at("Fundición · Materiales recuperados", 18, 6, 534, 32, 22, ui.GOLD, panel)
	icon(ui, "scrap", Rect2(20, 45, 42, 42), panel)
	var scrap = ui.label_at("Chatarra: %d" % model.scrap, 70, 48, 218, 34, 20, ui.TEXT, panel)
	scrap.name = "ScrapStock"
	icon(ui, "alloy", Rect2(300, 45, 42, 42), panel)
	var alloy = ui.label_at("Aleación: %d" % model.alloy, 350, 48, 200, 34, 20, ui.TEXT, panel)
	alloy.name = "AlloyStock"
	ui.label_at("%d chatarra → 1 aleación · Solo para armas y armaduras" % model.rate, 18, 90, 534, 26, 16, ui.TEXT, panel)
	var caption = "Fundir %d chatarra → %d aleación" % [model.smelt_scrap, model.batches] if model.batches > 0 else "Necesitás %d chatarra para fundir" % model.rate
	var button = ui.button(caption, 18, 124, 534, 40, smelt, model.batches > 0, panel)
	button.name = "SmeltMaterials"
	button.add_theme_font_size_override("font_size", 17)

static func reward(ui: Control, receipt: Dictionary) -> void:
	if int(receipt.get("scrap", 0)) <= 0: return
	var panel = ui.panel(392, 570, 496, 32)
	panel.name = "SalvageReward"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon(ui, "scrap", Rect2(8, 1, 30, 30), panel)
	var text = ui.label_at("+%d chatarra · Guardada para fundir en el taller" % receipt.scrap, 44, 0, 444, 32, 17, ui.TEXT, panel)
	text.name = "SalvageAmount"
