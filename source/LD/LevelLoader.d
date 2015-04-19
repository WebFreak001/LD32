module LD.LevelLoader;

import D2D;

import LD.Enemy;
import LD.TextureManager;

import std.json;
import std.algorithm;
import std.string;
import std.conv;
import jsonizer;

alias AddEnemyEvent = void delegate(Enemy enemy);

struct RepeatElement
{
	mixin JsonizeMe;
 @jsonize:

	int Repeat;
	FlowElement[] Child;
}

struct FlowElement
{
	mixin JsonizeMe;
 @jsonize:

	int Delay;
	bool   Symetric;
	string Monster;
}

class LevelLoader
{
private:
	AddEnemyEvent		  _onAddEnemy;
	void delegate()		  _onDone;
	int					  index;
	FlowElement[]		  elements;
	float				  time = 0;
	static TextureManager textures;

public:

	this(string content)
	{
		auto raw = fromJSON!(RepeatElement[])(parseJSON(content));
		foreach (entry; raw)
		{
			for (int i = 0; i < entry.Repeat; i++)
			{
				elements ~= entry.Child;
			}
		}
		index = elements.length - 1;
		std.algorithm.reverse(elements);
		_onAddEnemy = (e) {};
		_onDone = {};
	}

	void setEnemyListener(AddEnemyEvent listener)
	{
		_onAddEnemy = listener;
	}

	void setDoneListener(void delegate() listener)
	{
		_onDone = listener;
	}

	static Texture getTextureL(string type, int subType)
	{
		return textures.enemyL;
	}

	static Texture getTextureR(string type, int subType)
	{
		return textures.enemyR;
	}

	static void setTexture(TextureManager tex)
	{
		textures = tex;
	}

	static int getHealth(string type, int subType)
	{
		switch (type.toLower().strip())
		{
		case "basic":
			switch (subType)
			{
			case 0:
				return 7;
			case 1:
				return 12;
			case 2:
				return 20;
			default:
				return 0;
			}
		default:
			return 0;
		}
	}

	static Enemy createEnemy(string[] args)
	{
		string type	   = args[0];
		int	   subtype = 0;
		float  y	   = 0;
		bool   gravity = true;
		if (args.length > 1)
			foreach (string arg; args[1 .. $])
			{
				string[] sides = arg.split("=");
				if (sides.length > 2)
				{
					sides[1]	 = sides[1 .. $].join("=");
					sides.length = 2;
				}
				switch (sides[0].toLower().strip())
				{
				case "t":
					subtype = std.conv.to!(int)(sides[1].strip());
					break;
				case "y":
					y = std.conv.to!(float)(sides[1].strip());
					break;
				case "canfly":
					if (sides.length == 1)
					{
						gravity = false;
					}
					else
					{
						string rvalue = sides[1].toLower().strip();
						gravity = !(rvalue == "true" || rvalue == "1" || rvalue == "yes" || rvalue == "on");
					}
					break;
				default:
					break;
				}
			}
		Enemy enemy = new Enemy(getTextureL(type, subtype), getTextureR(type, subtype), -1100);
		enemy.health	= getHealth(type, subtype);
		enemy.maxHealth = getHealth(type, subtype);
		enemy.position	= vec2(-1100, -y);
		enemy.gravity	= gravity;
		return enemy;
	}

	void update(float delta)
	{
		time += delta * 1000;
		while (time >= elements[index].Delay)
		{
			_onAddEnemy(createEnemy(elements[index].Monster.split(":")));
			if (elements[index].Symetric)
			{
				Enemy e = createEnemy(elements[index].Monster.split(":"));
				e.position = vec2(1100, e.position.y);
				_onAddEnemy(e);
			}

			time -= elements[index].Delay;
			index--;
			if (index < 0)
				break;
		}
	}
}
