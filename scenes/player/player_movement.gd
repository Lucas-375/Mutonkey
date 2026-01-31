extends Resource
class_name PlayerMovement

var player: Player

func init(p: Player):
	player = p

func move(delta: float):
	var input = Vector2(
		Input.get_action_strength('move_right') - Input.get_action_strength("move_left"),
		Input.get_action_strength('move_down') - Input.get_action_strength('move_up')
	)
	
	player.velocity = input.normalized() * player.move_speed
	player.move_and_slide()
