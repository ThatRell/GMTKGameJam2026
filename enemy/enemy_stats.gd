class_name EnemyStats
extends Resource

# all of these are base stats for the base enemy
# just export diff stats if u wanna use something else
# for a different enemy scene

@export var max_health: float = 100.0
@export var move_speed: float = 50.0
@export var damage: float = 10.0

@export var detection_radius: float = 300.0
@export var attack_radius: float = 150.0

@export var attack_cooldown: float = 0.5
