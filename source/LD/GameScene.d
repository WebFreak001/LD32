module LD.GameScene;

import D2D;

import std.algorithm;

import LD.IScene;
import LD.TextureManager;
import LD.Rect;
import LD.Enemy;
import LD.Player;
import LD.IScene;
import LD.MenuScene;
import LD.LevelLoader;

class GameScene : IScene
{
private:
	IScene			  _next = null;
	TextureManager	  _texture;

	Player			  player;
	RepeatedRectangle floor;
	RepeatedRectangle floorTop;
	Enemy[]			  enemies;
	float			  shakeTime;

	LevelLoader		  level;
public:
	this(TextureManager tex)
	{
		_texture = tex;

		player	 = new Player(_texture.playerL, _texture.playerR, _texture.chair, this);
		floor	 = Rect.createRepeat(_texture.floor, vec2(-1152, 0), vec2(2304, 1024), vec2(34, 16));
		floorTop = Rect.createRepeat(_texture.floorTop, vec2(-1152, 0), vec2(2304, 64), vec2(34, 1));

		shakeTime = 0;

		level = new LevelLoader(import ("flow.json"));
		level.setEnemyListener((e)
		{
			enemies ~= e;
		});
	}

	@property TextureManager texture()
	{
		return _texture;
	}

	void shake(float strength)
	{
		shakeTime += strength * 0.1f;
		if (shakeTime > 1)
			shakeTime = 1;
	}

	void onEvent(Event event)
	{
	}

	void update(float delta)
	{
		shakeTime -= delta;
		if (shakeTime < 0)
			shakeTime = 0;

		level.update(delta);
		player.update(enemies, delta);

		if (player.dead)
		{
			_next = new MenuScene(_texture);
		}
	}

	void draw(IRenderTarget target)
	{
		target.clear(Color3.SkyBlue);
		matrixStack.push();

		matrixStack.top = player.camera;
		auto off = vec3(vec2(std.random.uniform(-1.0f, 1.0f), std.random.uniform(-1.0f, 1.0f)) * shakeTime * 7, 0);
		matrixStack.top = matrixStack.top * mat4.identity.translate(off.x, off.y, off.z);

		target.draw(floor);
		target.draw(floorTop);

		for (int i = enemies.length - 1; i >= 0; i--)
		{
			if (enemies[i].valid)
				target.draw(enemies[i]);
			else
				enemies = enemies.remove(i);
		}

		target.draw(player);

		matrixStack.pop();
	}

	IScene getNext()
	{
		return _next;
	}

	static void gainMoney(int t)
	{
		money += round(t * pow(1.35f, moneyMod));
	}

	static int money	 = 0;
	static int maxHealth = 1;
	static int damage	 = 1;
	static int speedMod	 = 1;
	static int jumpMod	 = 1;
	static int special	 = 0;
	static int moneyMod	 = 0;
}
