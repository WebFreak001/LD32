module LD.Player;

import D2D;

import LD32;

import LD.Keyboard;
import LD.ParticleSystem;
import LD.Enemy;
import LD.GameScene;

class Chair : RectangleShape
{
private:
	Player player;
	bool   visible	   = false;
	float  visibleTime = 0;
public:
	@property bool isVisible()
	{
		return visible;
	}

	this(Texture tex, Player player)
	{
		this.player = player;
		texture		= tex;
		setSize(vec2(100, 100));
		origin = vec2(0, 134);
	}

	void update(float delta)
	{
		if (visible)
		{
			if (rotation > 0)
				rotate(delta * 11);
			else
				rotate(delta * -11);

			visibleTime += delta;
			if (visibleTime > 0.15f)
			{
				visible = false;
			}
		}
		position = playerPos - vec2(0, 32);
	}

	bool attack(float dir)
	{
		if (!visible)
		{
			visibleTime = 0;
			visible		= true;
			rotation	= dir;
			return true;
		}
		return false;
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		if (visible)
			super.draw(target, shader);
	}

	vec2 playerPos = vec2(0, 0);
}

class Player : RectangleShape
{
private:
	ParticleSystem particles;
	Texture		   tl, tr;
	Chair		   chair;
	GameScene	   game;

	vec2		   entityPosition = vec2(0, 0);
	vec2		   lastCam		  = vec2(0, 0);
	float		   xa			  = 0;
	float		   ya			  = 0;
	float		   y			  = 0;
	bool		   left			  = false;
	int			   attackDir	  = -1;
	int			   lastEnemyJump  = -1;
	int			   health		  = 1;
	float		   invTime		  = 0;
	int			   kills		  = 0;
public:
	this(Texture left, Texture right, Texture chair, GameScene game)
	{
		super();
		setSize(vec2(64, 64));
		this.texture = right;
		origin		 = vec2(32, 64);
		tl			 = left;
		tr			 = right;
		this.chair	 = new Chair(chair, this);
		particles	 = new ParticleSystem(left, 1500);
		this.game	 = game;
		health		 = GameScene.maxHealth;
	}

	void update(Enemy[] enemies, float delta)
	{
		if (Keyboard.isKeyDown(SDLK_RIGHT))
		{
			if (chair.attack(0.3))
			{
				attackDir = 0;
				left	  = false;
			}
		}
		if (Keyboard.isKeyDown(SDLK_DOWN))
		{
			if (GameScene.special > 0 && chair.attack(1.75))
				attackDir = 1;
		}
		if (Keyboard.isKeyDown(SDLK_UP))
		{
			if (GameScene.special > 0 && chair.attack(4.9))
				attackDir = 3;
		}
		if (Keyboard.isKeyDown(SDLK_LEFT))
		{
			if (chair.attack(-0.5))
			{
				attackDir = 2;
				left	  = true;
			}
		}
		if (Keyboard.isKeyDown(SDLK_a))
		{
			xa	-= 1;
			left = true;
		}
		if (Keyboard.isKeyDown(SDLK_d))
		{
			xa	+= 1;
			left = false;
		}

		if (Keyboard.isKeyDown(SDLK_SPACE) && y < 0.1f)
		{
			ya = 8 + GameScene.jumpMod;
		}

		xa				 *= 0.8;
		y				 += ya;
		ya				 *= 0.995;
		ya				 -= 0.5;
		y				  = max(0, y);
		entityPosition.x += xa * 100 * delta * (0.95f + GameScene.speedMod * 0.05f);
		entityPosition.y  = -y;
		position		  = entityPosition;
		texture			  = left ? tl : tr;

		chair.playerPos = entityPosition;
		chair.update(delta);

		particles.update(delta);
		if (!chair.isVisible)
			attackDir = -1;

		invTime -= delta;

		foreach (enemy; enemies)
		{
			enemy.update(this, delta);
			if (enemy.inHitRange(this))
			{
				if (invTime <= 0)
				{
					invTime = 0.3f;
					health--;
					if (health == 0)
					{
						GameScene.money += kills * 5;
					}
				}
			}
			if (enemy.inRange(this))
			{
				if (attackDir == 0)
				{
					if (enemy.position.x > entityPosition.x)
					{
						if (enemy.damage(0.55f * pow(1.2f, GameScene.damage)))
						{
							game.shake(7);
							particles.addEmitter(game.texture.blood, enemy.position, 0.3, 2, 6);
							if (!enemy.valid)
								kills++;
						}
					}
				}
				if (attackDir == 1)
				{
					if (enemy.position.y > entityPosition.y)
					{
						if (enemy.damage(1.0f * pow(1.2f, GameScene.damage)))
						{
							if (Keyboard.isKeyDown(SDLK_SPACE) && lastEnemyJump != enemy.id)
							{
								ya			  = 8 + GameScene.jumpMod;
								lastEnemyJump = enemy.id;
							}
							game.shake(10);
							particles.addEmitter(game.texture.blood, enemy.position, 0.5, 2, 10);
							if (!enemy.valid)
								kills++;
						}
					}
				}
				if (attackDir == 2)
				{
					if (enemy.position.x < entityPosition.x)
					{
						if (enemy.damage(0.55f * pow(1.2f, GameScene.damage)))
						{
							game.shake(7);
							particles.addEmitter(game.texture.blood, enemy.position, 0.3, 2, 6);
							if (!enemy.valid)
								kills++;
						}
					}
				}
				if (attackDir == 3)
				{
					if (enemy.position.y < entityPosition.y)
					{
						if (enemy.damage(0.55f * pow(1.2f, GameScene.damage)))
						{
							game.shake(5);
							particles.addEmitter(game.texture.blood, enemy.position, 0.3, 2, 6);
							if (!enemy.valid)
								kills++;
						}
					}
				}
			}
		}

		if (entityPosition.y > -0.1f)
			lastEnemyJump = -1;
	}

	@property bool dead()
	{
		return health <= 0;
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		super.draw(target, shader);
		chair.draw(target, shader);
		particles.draw(target, shader);
	}

	mat4 camera()
	{
		lastCam = lastCam * 0.85 + position * 0.15;
		float x = -lastCam.x + 400;
		x = max(min(x, 1024), -1024 + 800);
		return mat4.identity.translate(x, -lastCam.y + 280, 0);
	}
}
