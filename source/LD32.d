module LD32;

import LD.TextureManager;
import LD.Player;
import LD.Rect;
import LD.Keyboard;
import LD.Enemy;
import LD.ParticleSystem;
import LD.GameEx;
import LD.Health;
import LD.IScene;
import LD.GameScene;
import LD.MenuScene;
import LD.Button;
import LD.Font;
import LD.LevelLoader;

import jsonizer;

import std.stdio;
import std.algorithm;

import D2D;

struct SaveFile
{
	mixin JsonizeMe;
 @jsonize:
	this(int money = 0, int maxHealth = 1, int damage = 1, int speedMod = 1, int jumpMod = 1, int special = 0, int moneyMod = 0)
	{
		this.money	   = money;
		this.maxHealth = maxHealth;
		this.damage	   = damage;
		this.speedMod  = speedMod;
		this.jumpMod   = jumpMod;
		this.special   = special;
		this.moneyMod  = moneyMod;
	}

	int money	  = 0;
	int maxHealth = 1;
	int damage	  = 1;
	int speedMod  = 1;
	int jumpMod	  = 1;
	int special	  = 0;
	int moneyMod  = 0;
}

class LD32 : GameEx
{
private:
	TextureManager _texture = new TextureManager();
	IScene		   currentScene;
	ShaderProgram  _post;

public:
	~this()
	{
		texture.dispose();
	}

	public @property TextureManager texture()
	{
		return _texture;
	}

	override void init()
	{
		windowTitle = "LD32";

		windowFlags |= WindowFlags.Resizable;
	}

	override void load()
	{
		_post = new ShaderProgram();
		Shader vertex = new Shader();
		vertex.load(ShaderType.Vertex, "#version 330
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex;
uniform mat4 transform;
uniform mat4 projection;
out vec2 texCoord;
void main()
{
	gl_Position = projection * transform * vec4(in_position, 1);
	texCoord = in_tex;
}
");
		Shader fragment = new Shader();
		fragment.load(ShaderType.Fragment, import ("post.frag"));
		_post.attach(vertex);
		_post.attach(fragment);
		_post.link();
		_post.bind();
		_post.registerUniform("tex");
		_post.registerUniform("transform");
		_post.registerUniform("projection");
		_post.registerUniform("vignette");
		_post.registerUniform("texelSize");
		_post.set("tex", 0);
		_post.set("vignette", 1);

		ShaderProgram fragShader = new ShaderProgram();
		Shader		  colorFrag	 = new Shader();
		colorFrag.load(ShaderType.Fragment, import ("font.frag"));
		fragShader.attach(vertex);
		fragShader.attach(colorFrag);
		fragShader.link();
		fragShader.bind();
		fragShader.registerUniform("tex");
		fragShader.registerUniform("transform");
		fragShader.registerUniform("projection");
		fragShader.registerUniform("color");
		fragShader.set("tex", 0);
		fragShader.set("color", vec4(1, 1, 1, 1));

		texture.load("chair.png");
		texture.load("playerL.png");
		texture.load("playerR.png");
		texture.load("floor.png");
		texture.load("floorTop.png");
		texture.load("enemyL.png");
		texture.load("enemyR.png");
		texture.load("blood.png");
		texture.load("vignette.png");
		texture.load("health.png");
		texture.load("healthBG.png");
		texture.load("button.png");
		texture.load("buttonHover.png");
		texture.load("buyBar.png");
		texture.load("buyBarBack.png");

		Health.setTexture(texture.health, texture.healthBG);
		Button.setTexture(texture.button, texture.buttonHover);
		Text.setTexture(texture, "font");
		Text.setShader(fragShader);
		LevelLoader.setTexture(texture);

		if (std.file.exists("save.json"))
		{
			try
			{
				SaveFile save = readJSON!(SaveFile)("save.json");
				GameScene.money		= save.money;
				GameScene.maxHealth = save.maxHealth;
				GameScene.damage	= save.damage;
				GameScene.speedMod	= save.speedMod;
				GameScene.jumpMod	= save.jumpMod;
				GameScene.special	= save.special;
				GameScene.moneyMod	= save.moneyMod;
			}
			catch (Exception e)
			{
				std.stdio.writeln(e);
			}
		}

		currentScene = new MenuScene(texture);
	}

	override void onEvent(Event event)
	{
		Keyboard.process(event);
		currentScene.onEvent(event);

		if (event.type == Event.Type.Close)
		{
			SaveFile save;
			save.money	   = GameScene.money;
			save.maxHealth = GameScene.maxHealth;
			save.damage	   = GameScene.damage;
			save.speedMod  = GameScene.speedMod;
			save.jumpMod   = GameScene.jumpMod;
			save.special   = GameScene.special;
			save.moneyMod  = GameScene.moneyMod;
			std.file.write("save.json", toJSONString(save));
		}
	}

	override void update(float delta)
	{
		currentScene.update(delta);
		if (currentScene.getNext() !is null)
		{
			currentScene = currentScene.getNext();
		}
	}

	override void draw()
	{
		currentScene.draw(window);

		if (cast(GameScene) currentScene)
		{
			_post.bind();
			_post.set("texelSize", vec2(1.0f / window.width, 1.0f / window.height));
			texture.vignette.bind(1);
			postShader = _post;
		}
		else
		{
			postShader = null;
		}
	}
}
