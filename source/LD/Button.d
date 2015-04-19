module LD.Button;

import D2D;

import LD.Font;

import std.signals;

class Button : RectangleShape
{
private:

	static Texture button, hover, font;
	bool		   _hover = false;
	vec2		   size;
	Text		   text;
public:
	this(string text, float scale)
	{
		texture	  = button;
		this.text = new Text(text, scale);
	}

	void setText(string text, float scale)
	{
		this.text = new Text(text, scale);
	}

	override void setSize(const vec2 s)
	{
		size = s;
		super.setSize(s);
	}

	void onEvent(Event event)
	{
		if (event.type == Event.Type.MouseMoved)
		{
			if (event.x >= position.x && event.y >= position.y && event.x <= position.x + size.x && event.y <= position.y + size.y)
			{
				texture = hover;
				_hover	= true;
			}
			else
			{
				texture = button;
				_hover	= false;
			}
		}
		if (event.type == Event.Type.MouseButtonReleased)
		{
			if (event.mousebutton == 1 && _hover)
			{
				emit();
			}
		}
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		super.draw(target, shader);
		text.position = position + vec2((size.x - text.textWidth) * 0.5, (size.y - text.lineHeight) * 0.5);
		text.draw(target, shader);
	}

	mixin Signal;

	static void setTexture(Texture button, Texture hover)
	{
		Button.button = button;
		Button.hover  = hover;
	}
}
