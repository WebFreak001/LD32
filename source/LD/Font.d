module LD.Font;

import D2D;

import LD.Rect;
import LD.TextureManager;

import std.file;

struct CharInfo
{
	char id;
	int	 x, y, width, height;
	int	 xoffset, yoffset;
	int	 xadvance;
	int	 textureN;
}

struct Kerning
{
	char first;
	char second;
	byte amount;
}

struct FontInfo
{
	int		  width, height;
	int		  lineHeight;
	int		  baseY;
	Kerning[] kernings;
	CharInfo[char] characters;
}

class Text : IDrawable
{
private:
	static
	{
		FontInfo	  info;
		Texture[int]  fonts;
		ShaderProgram shader;
	}

	RepeatedRectangle[] characters;
	vec2				pos;
	vec2				_scaling;
	vec4				_color = vec4(1, 1, 1, 1);
	float				width, lh;

public:
	this(string text, float scale)
	{
		int	  x		  = 0;
		float iWidth  = 1.0f / info.width;
		float iHeight = 1.0f / info.height;
		foreach (i, c; text)
		{
			if ((c in info.characters) !is null)
			{
				byte kerning = 0;
				if (i > 0)
				{
					kerning = getKerning(text[i - 1], c);
				}
				auto r = Rect.createRepeatOff(fonts[info.characters[c].textureN],
											  vec2(x + info.characters[c].xoffset + kerning, info.characters[c].yoffset) * scale,
											  vec2(info.characters[c].width, info.characters[c].height) * scale,
											  vec2(info.characters[c].x * iWidth, info.characters[c].y * iHeight) +
											  vec2(info.characters[c].width * iWidth, info.characters[c].height * iHeight),
											  vec2(info.characters[c].x * iWidth, info.characters[c].y * iHeight));
				characters ~= r;
				x += info.characters[c].xadvance;
			}
			else
			{
				std.stdio.writeln("CHARACTER ", c, " NOT FOUND");
			}
		}
		pos		 = vec2(0, 0);
		_scaling = vec2(1, 1);
		width	 = x * scale;
		lh		 = info.lineHeight * scale;
	}

	public void set(string text, float scale)
	{
		int	  x		  = 0;
		float iWidth  = 1.0f / info.width;
		float iHeight = 1.0f / info.height;
		characters.length = 0;
		foreach (i, c; text)
		{
			if ((c in info.characters) !is null)
			{
				byte kerning = 0;
				if (i > 0)
				{
					kerning = getKerning(text[i - 1], c);
				}
				auto r = Rect.createRepeatOff(fonts[info.characters[c].textureN],
											  vec2(x + info.characters[c].xoffset + kerning, info.characters[c].yoffset) * scale,
											  vec2(info.characters[c].width, info.characters[c].height) * scale,
											  vec2(info.characters[c].x * iWidth, info.characters[c].y * iHeight) +
											  vec2(info.characters[c].width * iWidth, info.characters[c].height * iHeight),
											  vec2(info.characters[c].x * iWidth, info.characters[c].y * iHeight));
				characters ~= r;
				x += info.characters[c].xadvance;
			}
			else
			{
				std.stdio.writeln("CHARACTER ", c, " NOT FOUND");
			}
		}
		width = x * scale;
		lh	  = info.lineHeight * scale;
	}

	@property float textWidth()
	{
		return width;
	}

	@property float lineHeight()
	{
		return lh;
	}

	static byte getKerning(char a, char b)
	{
		foreach (kerning; info.kernings)
		{
			if (kerning.first == a && kerning.second == b)
				return kerning.amount;
		}
		return 0;
	}

	@property ref vec2 position()
	{
		return pos;
	}

	@property ref vec4 color()
	{
		return _color;
	}

	void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		matrixStack.push();
		matrixStack.top = matrixStack.top * mat4.translation(position.x, position.y, 0);
		foreach (c; characters)
		{
			this.shader.bind();
			this.shader.set("color", _color);
			c.draw(target, this.shader);
		}
		matrixStack.pop();
	}

	static void setShader(ShaderProgram shader)
	{
		Text.shader = shader;
	}

	static void setTexture(TextureManager textures, string fontPath)
	{
		static import std.regex;
		import std.conv;

		string[] lines = readText(fontPath ~ ".fnt").split("\n");
		auto	 reg   = std.regex.regex(r"\s+");

		foreach (line; lines)
		{
			if (line.strip() == "")
				continue;
			string[] parts = std.regex.split(line, reg);
			string	 type  = parts[0];
			parts = parts[1 .. $];
			switch (type)
			{
			case "info":
				break;
			case "chars":
				break;
			case "kernings":
				break;
			case "common":
				foreach (part; parts)
				{
					if (part.strip() == "")
						continue;
					string[] sides = part.split("=");
					switch (sides[0])
					{
					case "lineHeight":
						info.lineHeight = parse!(int)(sides[1]);
						break;
					case "base":
						info.baseY = parse!(int)(sides[1]);
						break;
					case "scaleW":
						info.width = parse!(int)(sides[1]);
						break;
					case "scaleH":
						info.height = parse!(int)(sides[1]);
						break;
					case "pages":
						break;
					case "packed":
						break;
					case "alphaChnl":
						break;
					case "redChnl":
						break;
					case "greenChnl":
						break;
					case "blueChnl":
						break;
					default:
						std.stdio.writeln("NOT FOUND: common.", sides[0]);
						break;
					}
				}
				break;
			case "page":
				int	   pgID = 0;
				string file = "";
				foreach (part; parts)
				{
					if (part.strip() == "")
						continue;
					string[] sides = part.split("=");
					switch (sides[0])
					{
					case "id":
						pgID = parse!(int)(sides[1]);
						break;
					case "file":
						import std.algorithm;
						file = sides[1].strip('"');
						break;
					default:
						std.stdio.writeln("NOT FOUND: page.", sides[0]);
						break;
					}
				}
				textures.tryLoad(file);
				fonts[pgID] = textures.get(file[0 .. file.indexOf(".")]);
				break;
			case "char":
				CharInfo c;
				foreach (part; parts)
				{
					if (part.strip() == "")
						continue;
					string[] sides = part.split("=");
					switch (sides[0])
					{
					case "id":
						c.id = cast(char) parse!(int)(sides[1]);
						break;
					case "x":
						c.x = parse!(int)(sides[1]);
						break;
					case "y":
						c.y = parse!(int)(sides[1]);
						break;
					case "width":
						c.width = parse!(int)(sides[1]);
						break;
					case "height":
						c.height = parse!(int)(sides[1]);
						break;
					case "xoffset":
						c.xoffset = parse!(int)(sides[1]);
						break;
					case "yoffset":
						c.yoffset = parse!(int)(sides[1]);
						break;
					case "xadvance":
						c.xadvance = parse!(int)(sides[1]);
						break;
					case "page":
						c.textureN = parse!(int)(sides[1]);
						break;
					case "chnl":
						break;
					default:
						std.stdio.writeln("NOT FOUND: char.", sides[0]);
						break;
					}
				}
				info.characters[c.id] = c;
				break;
			case "kerning":
				Kerning kerning;
				foreach (part; parts)
				{
					if (part.strip() == "")
						continue;
					string[] sides = part.split("=");
					switch (sides[0])
					{
					case "first":
						kerning.first = cast(char) parse!(int)(sides[1]);
						break;
					case "second":
						kerning.second = cast(char) parse!(int)(sides[1]);
						break;
					case "amount":
						kerning.amount = parse!(byte)(sides[1]);
						break;
					default:
						std.stdio.writeln("NOT FOUND: kerning.", sides[0]);
						break;
					}
				}
				info.kernings ~= kerning;
				break;
			default:
				std.stdio.writeln("NOT FOUND: ", type);
				break;
			}
		}
	}
}
