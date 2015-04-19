module LD.ParticleSystem;

import D2D;
import LD.Rect;

static import std.random;

class ParticleInfo : IDrawable, IVerifiable
{
	float		   time;
	vec2		   offset;
	vec2		   origin;
	vec2		   size;
	RectangleShape particle;
	float		   maxTime;
	bool		   gravity;

	this(Texture tex, vec2 size, float ttl)
	{
		this.size = size;
		time	  = ttl + 1;
		offset	  = -size;
		particle  = Rect.create(tex, -size, size);
		maxTime	  = ttl;
	}

	void respawn(vec2 pos, vec2 off, float ttl, Texture tex, bool gravity)
	{
		origin			  = pos;
		particle.position = vec2(0, 0);
		offset			  = off;
		maxTime			  = ttl;
		particle.texture  = tex;
		time			  = 0;
		this.gravity	  = gravity;
	}

	void update(float delta)
	{
		time += delta;
		if (gravity)
			offset.y += 10 * delta;
		origin += offset * delta * 100;
	}

	void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		if (time < maxTime)
		{
			particle.position = origin;
			particle.draw(target, shader);
		}
	}

	@property bool valid()
	{
		return time < maxTime;
	}
}

class EmitterInfo : IVerifiable
{
	vec2	position;
	float	time;
	int		strength;
	float	maxTime;
	float	pttl;
	Texture tex;
	bool	gravity;

	this(Texture tex, vec2 pos, float maxTime, float particleMaxTime, int strength = 1, bool gravity = true)
	{
		this.tex	  = tex;
		position	  = pos;
		this.maxTime  = maxTime;
		this.strength = strength;
		pttl		  = particleMaxTime;
		time		  = 0;
		this.gravity  = gravity;
	}

	void update(float delta)
	{
		time += delta;
	}

	vec2 getOffset()
	{
		return vec2(std.random.uniform(-2.0f, 2.0f), std.random.uniform(-6.0f, -4.0f));
	}

	@property bool valid()
	{
		return time < maxTime;
	}
}

class ParticleSystem : IDrawable
{
private:
	ParticleInfo[] particles;
	EmitterInfo[]  emitter;
	float		   time = 0;

public:
	this(Texture base, int length, vec2 size = vec2(3, 3))
	{
		particles = new ParticleInfo[length];
		for (int i = 0; i < length; i++)
			particles[i] = new ParticleInfo(base, size, 0);
	}

	void addEmitter(Texture tex, vec2 pos, float ttl, float pttl, int strength = 1, bool gravity = true)
	{
		for (int i = 0; i < emitter.length; i++)
		{
			if (!emitter[i].valid)
			{
				emitter[i] = new EmitterInfo(tex, pos, ttl, pttl, strength);
				return;
			}
		}
		emitter ~= new EmitterInfo(tex, pos, ttl, pttl, strength, gravity);
	}

	void update(float delta)
	{
		bool spawnParticles = false;

		time += delta;
		if (time > 0.01666666f)
		{
			time		   = 0;
			spawnParticles = true;
		}

		for (int i = 0; i < emitter.length; i++)
		{
			if (emitter[i].valid)
			{
				emitter[i].update(delta);

				if (spawnParticles)
				{
 LFound:
					for (int j = 0; j < emitter[i].strength; j++)
					{
						for (int l = 0; l < particles.length; l++)
						{
							if (!particles[l].valid)
							{
								particles[l].respawn(emitter[i].position, emitter[i].getOffset(), emitter[i].pttl, emitter[i].tex, emitter[i].gravity);
								continue LFound;
							}
						}
					}
				}
			}
		}

		foreach (ref particle; particles)
			particle.update(delta);
	}

	void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		foreach (ref particle; particles)
			particle.draw(target, shader);
	}
}
