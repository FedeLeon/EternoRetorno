extends RefCounted
# Optional danger is announced before the room transaction, including touch.
static func enter(ui: Control, id: int) -> void:
 if id not in ui.game.available_nodes(): return
 var node: Dictionary=ui.game.run.nodes[id]
 if not node.has("risk"):
  ui.act(func(): ui.game.enter_node(id));return
 ui.close_modal()
 ui.overlay=preload("res://src/ui/components/dialog_view.gd").build(ui,node.risk.name,node.risk.warning,[
  {"text":"Entrar al riesgo", "callback":func():ui.close_modal();ui.act(func():ui.game.enter_node(id))},
  {"text":"Volver a los caminos" if ui.screen == "paths" else "Volver al mapa", "callback":ui.close_modal}])
