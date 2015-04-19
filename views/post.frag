#version 330

uniform sampler2D tex;
uniform sampler2D vignette;
in vec2 texCoord;

uniform vec2 texelSize;
uniform vec2 shakeDir;
uniform float shakeTime;

layout(location = 0) out vec4 out_frag_color;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 get(vec2 coord)
{
	if(texture(vignette, clamp(coord, 0, 1)).r < 0.98)
		return texture(tex, clamp(coord + 0.05 * (1.5 - texture(vignette, clamp(coord, 0, 1)).r * 1.5) * vec2(rand(coord), rand(-coord * 5)), 0.000001, 0.999999)).rgb;
	return texture(tex, clamp(coord, 0, 1)).rgb;
}

void main()
{
	vec3 color = get(texCoord);

	if(texture(vignette, texCoord).r <= 0.95)
	{
		color += get(texCoord + vec2(texelSize.x, 0));
		color += get(texCoord + vec2(-texelSize.x, 0));
		color += get(texCoord + vec2(0, texelSize.y));
		color += get(texCoord + vec2(0, -texelSize.y));
		color += get(texCoord + vec2(texelSize.x, texelSize.y));
		color += get(texCoord + vec2(texelSize.x, -texelSize.y));
		color += get(texCoord + vec2(texelSize.x, texelSize.y));
		color += get(texCoord + vec2(-texelSize.x, texelSize.y));
		color /= 9.0;
	}

	if(texture(vignette, texCoord).r <= 0.85)
	{
		color += get(texCoord + vec2(texelSize.x, 0) * 2);
		color += get(texCoord + vec2(-texelSize.x, 0) * 2);
		color += get(texCoord + vec2(0, texelSize.y) * 2);
		color += get(texCoord + vec2(0, -texelSize.y) * 2);
		color += get(texCoord + vec2(texelSize.x, texelSize.y) * 2);
		color += get(texCoord + vec2(texelSize.x, -texelSize.y) * 2);
		color += get(texCoord + vec2(texelSize.x, texelSize.y) * 2);
		color += get(texCoord + vec2(-texelSize.x, texelSize.y) * 2);
		color /= 9.0;
	}

	out_frag_color = vec4(color, 1);
}
