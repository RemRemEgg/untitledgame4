shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
const float FOV = 135./180.;

void fragment() {
	//if (UV.x + UV.y < 1.0) {
	//if (UV.y < 0.5) {
		//COLOR = texture(screen_texture, UV, 0.0);
	//} else {
		//vec3 pos = UV.xyx;
		//pos -= vec3(0.5, 0.5, 0.0);
		//pos.y *= SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y;
		//
		//pos.z = length(pos.xy);
		//pos = normalize(pos);
		//
		//pos.y /= SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y;
		//pos += vec3(0.5, 0.5, 0.0);
		//pos -= vec2(0.5, 0.5);
		//pos *= 2.;
		//pos = pow(abs(pos), vec2(1.5, 1.5)) * vec2(sign(pos.x), sign(pos.y));
		////pos *= pos * vec2(sign(pos.x), sign(pos.y));
		//pos /= 2.;
		//pos += vec2(0.5, 0.5);
		//pos = floor(pos * 20.0) / 20.0;
		//COLOR = vec4(pos.x, pos.y, 0.0, 1.0);
		
		//u
		vec2 pos = UV;
		//x
		pos -= vec2(0.5, 0.5);
		pos *= 2.0;
		pos.y *= SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y;
		//x'
		pos = vec2(asin(pos.x * FOV), asin(pos.y * FOV));
		pos *= 1.0/asin(FOV);
		//float r1 = length(pos);
		//float r3 = pow(r1, 0.5);
		//pos = (pos / r3) * r1;
		//float r = length(pos);
		//float r2 = pos.x*pos.x + pos.y*pos.y;
		
		
		//u'
		pos.y *= SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x;
		pos /= 2.0;
		pos += vec2(0.5, 0.5);
		
		
		COLOR = texture(screen_texture, pos, 0.0);
		pos = floor(pos * 20.0) / 20.0;
		//COLOR = vec4(pos.x, pos.y, 0.0, 1.0);
	//}
}