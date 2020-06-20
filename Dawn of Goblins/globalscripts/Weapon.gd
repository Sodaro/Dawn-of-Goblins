extends Spatial

class_name Weapon

enum WeaponType {None, Sword, Bow}
export(WeaponType) var weaponType
export(int) var damage = 5
export(float) var knockbackForce = 25
var excludeArray: Array = []

var SwordStats = {"Damage": damage, "Force": knockbackForce}
