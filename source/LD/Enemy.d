module LD.Enemy;

import std.stdio;

import D2D;

import LD.Player;
import LD.Health;
import LD.GameScene;

int g_enemies = 0;

class Enemy : RectangleShape, IVerifiable
{
public:
	bool	left;
	Texture tl, tr;
	float	health	  = 7;
	int		maxHealth = 7;
	float	invTime;
	Health	healthI;
	bool	gravity = true;
	float	xa		= 0;
	int		id;

	this(Texture left, Texture right, float x)
	{
		super();
		setSize(vec2(64, 64));
		texture	 = left;
		tl		 = left;
		tr		 = right;
		origin	 = vec2(32, 64);
		position = vec2(x, 0);
		invTime	 = 0;
		healthI	 = new Health(60);
		id		 = g_enemies;
		g_enemies++;
	}

	void update(Player player, float delta)
	{
		if (gravity)
		{
			position = vec2(position.x, 0);
			if (std.math.abs(player.position.x - position.x) > 64)
			{
				if (player.position.x < position.x)
				{
					position = vec2(position.x - delta * 100, position.y);
					left	 = true;
				}
				else
				{
					position = vec2(position.x + delta * 100, position.y);
					left	 = false;
				}
			}
		}
		else
		{
			if (player.position.x < position.x)
			{
				left = true;
			}
			else
			{
				left = false;
			}
			xa		+= left ? -0.1f : 0.1f;
			xa		*= 0.99f;
			position = vec2(position.x + xa, position.y);
		}
		texture	 = left ? tl : tr;
		invTime -= delta;
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		super.draw(target, shader);
		healthI.position = position + vec2(-30, 2);
		healthI.draw(target, shader);
	}

	bool inRange(Player player)
	{
		return (position - player.position - vec2(0, 20)).length_squared < 20000;
	}

	bool inHitRange(Player player)
	{
		return (position - player.position).length_squared < 5000;
	}

	bool valid()
	{
		return health > 0;
	}

	bool damage(float dmg = 1)
	{
		if (invTime <= 0)
		{
			health -= dmg;
			invTime = 0.2f;
			healthI.set(health / cast(float) maxHealth);
			if (health <= 0)
			{
				GameScene.gainMoney(1);
			}
			return true;
		}
		return false;
	}
}
