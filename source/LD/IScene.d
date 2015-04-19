module LD.IScene;

import D2D;

interface IScene
{
	void onEvent(Event event);
	void update(float delta);
	void draw(IRenderTarget target);
	IScene getNext();
}
