extends Node

func lerp_array(from_array, to_array, speed):
	for i in range(0, from_array.size()):
		from_array[i] = lerp(from_array[i], to_array[i], speed)
	return from_array
