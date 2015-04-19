module LD.Health;

import D2D;
import LD.Rect;

class Health
{
private:
	RectangleShape rect;
	RectangleShape bg;
	int			   maxLen;
	static Texture texture;
	static Texture bgTexture;

public:
	this(int maxLen)
	{
		this.maxLen = maxLen;
		rect		= Rect.create(texture, vec2(0, 0), vec2(maxLen, 8));
		bg			= Rect.create(bgTexture, vec2(0, 0), vec2(maxLen, 8));
	}

	void set(float percentage)
	{
		rect.setSize(vec2(maxLen * percentage, 8));
	}

	@property vec2 position()
	{
		return rect.position;
	}

	@property void position(vec2 p)
	{
		bg.position	  = p;
		rect.position = p;
	}

	void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		bg.draw(target, shader);
		rect.draw(target, shader);
	}

	static void setTexture(Texture tex, Texture bg)
	{
		texture	  = tex;
		bgTexture = bg;
	}
}
