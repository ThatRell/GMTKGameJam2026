extends Node

@warning_ignore_start("unused_signal")

# Scene Navigation
signal on_trigger_player_spawn

# Bullet Handling
signal on_player_bullet_shot
signal on_enemy_bullet_shot
signal on_player_blanked

# UI
signal on_current_spell_updated
signal on_player_lose_hp
signal on_player_gain_hp
signal reset_player_hp_bar
signal on_text_trigger
