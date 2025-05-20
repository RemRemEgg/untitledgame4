shader_type sky;

const float SCALE = 18.0;
const float DENSITY = 0.005;
const float BRIGHTNESS = 0.64;

const vec3 BLACK = vec3(0, 0, 0);
const vec3 CMP = vec3(1.0, 1.0, 1.0) * 0.08;
const float dxz = BRIGHTNESS / DENSITY;

int pkn(int a, int b, int c) {
	a ^= a << 13;
	a ^= (a^c) >> 17;
	a ^= a << 5;
	b ^= b << 11;
	b ^= (b^c) >> 15;
	b ^= b << 7;
	return a^~b^~c;
}

void sky() {
	if (AT_CUBEMAP_PASS) { COLOR = vec3(0, 0, 0);
    } else {
		COLOR = BLACK;
		for (float ii = 0.5; ii < 2.0; ii += 0.7) {
			float x = SCREEN_UV.x*SCALE*16.0*(4.0-ii); //int(SKY_COORDS.x * SCALE * sin( floor(SKY_COORDS.y*SCALE) /SCALE*PI))
			float y = SCREEN_UV.y*SCALE*9.00*(4.0-ii); //int(SKY_COORDS.y * SCALE)
			float z1 = float(abs(pkn(int(x + POSITION.x*ii*0.1),int(y + POSITION.z*ii*0.1),int(ii*157348.0))))/35565.0;
			z1 -= floor(z1);
			if (z1 > DENSITY) z1 = 0.0;
			COLOR += vec3(z1 * dxz);
		}
		COLOR = min(COLOR, vec3(1, 1, 1));
	}
}