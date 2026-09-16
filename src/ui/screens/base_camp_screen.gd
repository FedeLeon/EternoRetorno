extends RefCounted

# Camp presentation; construction and navigation are controller callbacks.
static func build(ui: Control, profile: Dictionary, has_active_run: bool, actions: Dictionary) -> void:
	ui.panel(24, 20, 570, 92)
	ui.label_at("ETERNO RETORNO · EL CAMPAMENTO", 42, 28, 530, 26, 17, ui.GOLD)
	ui.label_at("Un lugar al que volver", 42, 56, 530, 40, 28, ui.TEXT)
	ui.button("Menú", 1134, 30, 110, 48, actions.home)
	ui.camp_hotspot("CampExit", Rect2(960, 115, 155, 135), "Preparar aventura →", func():
		actions.prepare.call())
	var plots = [Rect2(110, 279, 276, 47), Rect2(836, 299, 256, 40), Rect2(75, 414, 319, 59), Rect2(933, 476, 284, 56)]
	ui.label_at("Almas: %d" % profile.souls, 670, 30, 380, 48, 26, ui.GOLD)
	for i in range(plots.size()):
		if i == 0:
			ui.camp_hotspot("Plot0", plots[0], "Mercado · Entrar" if profile.buildings.get("market", false) else "Solar 1 · Mercado", actions.market)
			continue
		ui.camp_hotspot("Plot%d" % i, plots[i], "Solar %d · Sin construir" % (i + 1), func():
			ui.show_modal("Solar disponible", "Aquí podrás construir un edificio para tu campamento.\nLas construcciones y sus ventajas todavía no están disponibles.", "Entendido", actions.close_modal))
	ui.camp_hotspot("CampTent", Rect2(427, 240, 180, 107), "Refugio de personajes", func():
		ui.show_modal("Refugio de personajes", "Este será el lugar para mejorar a tus personajes entre aventuras.\nLas mejoras todavía no están disponibles.", "Entendido", actions.close_modal))
	ui.panel(24, 647, 1232, 65)
	ui.label_at("Tocá el arco de piedra para preparar una nueva aventura.", 42, 657, 775, 42, 20, ui.TEXT)
	if has_active_run:
		ui.button("Continuar aventura →", 916, 657, 320, 44, actions.continue_run)
	else:
		ui.label_at("%d aventuras · %d victorias" % [profile.attempts, profile.victories], 926, 657, 308, 42, 17, ui.GOLD)

