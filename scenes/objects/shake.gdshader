shader_type canvas_item;

uniform highp float shake_intensity = 0.0;
uniform float shake_speed = 20.0;

void vertex() {
	highp vec2 shake = vec2(0.0);

	if(VERTEX.y < 1.0) {
		shake.x = sin(TIME * shake_speed + VERTEX.y) * (shake_intensity);
	}

	VERTEX.xy += shake;
}
