module LD.TextureManager;

import D2D;

import std.algorithm : canFind;

class TextureManager : IDisposable
{
private:
	Texture[string] textures;
	string[] loaded;
public:
	~this()
	{
		dispose();
	}

	void load(string tex)
	{
		string name = tex[0 .. tex.indexOf(".")];
		assert(name[$ - 1] != '.');

		if (!std.file.exists(tex))
			throw new Exception("Texture " ~ tex ~ " does not exist!");

		if (loaded.canFind(tex))
		{
			throw new Exception("Texture is already loaded! " ~ name ~ ": " ~ tex);
		}

		if ((name in textures) !is null)
		{
			throw new Exception("Name is already defined! " ~ name ~ ": " ~ tex);
		}

		textures[name] = new Texture(tex);
		loaded ~= tex;
	}

	void tryLoad(string tex)
	{
		string name = tex[0 .. tex.indexOf(".")];
		assert(name[$ - 1] != '.');

		if (!std.file.exists(tex))
			throw new Exception("Texture " ~ tex ~ " does not exist!");

		if (loaded.canFind(tex))
		{
			return;
		}

		if ((name in textures) !is null)
		{
			throw new Exception("Name is already defined! " ~ name ~ ": " ~ tex);
		}

		textures[name] = new Texture(tex);
		loaded ~= tex;
	}

	void dispose()
	{
		foreach (string name, ref Texture tex; textures)
		{
			tex.dispose();
			textures.remove(name);
		}
	}

	Texture get(string name)
	{
		assert((name in textures) !is null, "Texture not found! " ~ name);
		return textures[name];
	}

	Texture opDispatch(string name)()
	{
		return get(name);
	}
}
