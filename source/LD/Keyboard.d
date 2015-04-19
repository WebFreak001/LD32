module LD.Keyboard;

import std.stdio;

import D2D;

class Keyboard
{
	static :
private:
	bool[int] pressed;

public:
	void process(Event event)
	{
		if (event.type == Event.Type.KeyPressed)
		{
			pressed[event.key] = true;
		}
		if (event.type == Event.Type.KeyReleased)
		{
			pressed[event.key] = false;
		}
	}

	bool isKeyDown(int vk)
	{
		return (vk in pressed) == null ? false : pressed[vk];
	}
}
