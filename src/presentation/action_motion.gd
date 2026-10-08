extends RefCounted
# Visual classification only; each receipt carries the card data that caused it.
static func for_card(card: Dictionary, hit: int = 0) -> String:
	if card.get("charge", false): return "charged"
	if int(card.get("poison", 0)) > 0 and int(card.get("damage", 0)) == 0: return "skill"
	if int(card.get("damage", 0)) == 0: return "heal" if card.get("heal", 0) > 0 else "guard" if card.get("block",0)>0 else "skill"
	if card.get("target", "") == "all_enemies": return "sweep"
	if int(card.get("hits", 1)) > 1: return ["thrust","sweep","charged"][hit % 3]
	if int(card.get("cost", 1)) >= 2: return "charged"
	if "bash" in card.get("id", "") or card.get("pierce", false): return "thrust"
	return "charged" if int(card.get("cost", 1)) >= 2 else "sweep"
