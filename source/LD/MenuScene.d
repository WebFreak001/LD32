module LD.MenuScene;

import D2D;

import std.algorithm;

import LD.IScene;
import LD.TextureManager;
import LD.Rect;
import LD.Enemy;
import LD.Player;
import LD.IScene;
import LD.Button;
import LD.Font;
import LD.GameScene;

immutable char Kappa = 12;

class BuyBar : Transformable, IDrawable
{
private:
	RepeatedRectangle bg, fg;
public:
	this(Texture bg, Texture fg, int steps)
	{
		this.bg = Rect.createRepeat(bg, vec2(0, 0), vec2(steps * 24, 32), vec2(steps, 1));
		this.fg = Rect.createRepeat(fg, vec2(0, 0), vec2(steps * 24, 32), vec2(steps, 1));
	}

	void set(int i)
	{
		fg.setSize(vec2(i * 24, 32));
		fg.setRepeat(vec2(i, 1));
		fg.create();
	}

	void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		bg.position = position;
		bg.origin	= origin;
		bg.scaling	= scaling;
		bg.rotation = rotation;
		fg.position = position;
		fg.origin	= origin;
		fg.scaling	= scaling;
		fg.rotation = rotation;

		bg.draw(target, shader);
		fg.draw(target, shader);
	}
}

class MenuScene : IScene
{
private:
	IScene		   _next = null;
	TextureManager _texture;

	IDrawable[]	   ui;

	Text		   money;
	Button		   moneyAdd;

	Button		   healthBtn;
	Button		   dmgBtn;
	Button		   speedBtn;
	Button		   jumpBtn;
	Button		   specialBtn;
	Button		   moneyBtn;

	BuyBar		   healthBar;
	BuyBar		   dmgBar;
	BuyBar		   speedBar;
	BuyBar		   jumpBar;
	BuyBar		   specialBar;
	BuyBar		   moneyBar;
public:
	this(TextureManager tex)
	{
		_texture = tex;

		string text = "PLAY";
		if (std.random.uniform(0, 10000) == 0)
			text ~= Kappa;

		addButton(text, 0.6f, vec2(40, 400), vec2(720, 60), &replay);
		money	 = addText("$: " ~ to!string(GameScene.money), 0.5f, vec2(40, 20), vec4(0, 0, 0, 1));
		moneyAdd = addButton("+", 0.5f, vec2(50 + money.textWidth, 25), vec2(32, 32), &replay);

		addText("Health", 0.5f, vec2(40, 80), vec4(0, 0, 0, 1));
		addText("Damage", 0.5f, vec2(40, 120), vec4(0, 0, 0, 1));
		addText("Speed", 0.5f, vec2(40, 160), vec4(0, 0, 0, 1));
		addText("Jump", 0.5f, vec2(40, 200), vec4(0, 0, 0, 1));
		addText("Special", 0.5f, vec2(40, 240), vec4(0, 0, 0, 1));
		addText("Money", 0.5f, vec2(40, 280), vec4(0, 0, 0, 1));

		healthBar  = addBuy(GameScene.maxHealth, 5, vec2(300, 84));
		dmgBar	   = addBuy(GameScene.damage, 7, vec2(300, 124));
		speedBar   = addBuy(GameScene.speedMod, 4, vec2(300, 164));
		jumpBar	   = addBuy(GameScene.jumpMod, 4, vec2(300, 204));
		specialBar = addBuy(GameScene.special, 2, vec2(300, 244));
		moneyBar   = addBuy(GameScene.moneyMod, 8, vec2(300, 284));

		healthBtn  = addButton(to!string(round(100 * pow(1.5f, GameScene.maxHealth))) ~ "$", 0.4f, vec2(500, 84), vec2(100, 32), &buyHealth);
		dmgBtn	   = addButton(to!string(round(80 * pow(1.35f, GameScene.damage))) ~ "$", 0.4f, vec2(500, 124), vec2(100, 32), &buyDamage);
		speedBtn   = addButton(to!string(round(70 * pow(1.3f, GameScene.speedMod))) ~ "$", 0.4f, vec2(500, 164), vec2(100, 32), &buySpeed);
		jumpBtn	   = addButton(to!string(round(80 * pow(1.41f, GameScene.jumpMod))) ~ "$", 0.4f, vec2(500, 204), vec2(100, 32), &buyJump);
		specialBtn = addButton(to!string(round(500 * pow(1.8f, GameScene.special))) ~ "$", 0.4f, vec2(500, 244), vec2(100, 32), &buySpecial);
		moneyBtn   = addButton(to!string(round(60 * pow(1.2f, GameScene.moneyMod))) ~ "$", 0.4f, vec2(500, 284), vec2(100, 32), &buyMoney);
	}

	void buyHealth()
	{
		if (GameScene.money >= round(100 * pow(1.5f, GameScene.maxHealth)) && GameScene.maxHealth < 5)
		{
			GameScene.money -= round(100 * pow(1.5f, GameScene.maxHealth));
			GameScene.maxHealth++;
			healthBar.set(GameScene.maxHealth);
			healthBtn.setText(to!string(round(100 * pow(1.5f, GameScene.maxHealth))) ~ "$", 0.4f);
			updateMoney();
		}
	}

	void buyDamage()
	{
		if (GameScene.money >= round(80 * pow(1.35f, GameScene.damage)) && GameScene.damage < 7)
		{
			GameScene.money -= round(80 * pow(1.35f, GameScene.damage));
			GameScene.damage++;
			dmgBar.set(GameScene.damage);
			dmgBtn.setText(to!string(round(80 * pow(1.35f, GameScene.damage))) ~ "$", 0.4f);
			updateMoney();
		}
	}

	void buySpeed()
	{
		if (GameScene.money >= round(70 * pow(1.3f, GameScene.speedMod)) && GameScene.speedMod < 4)
		{
			GameScene.money -= round(70 * pow(1.3f, GameScene.speedMod));
			GameScene.speedMod++;
			speedBar.set(GameScene.speedMod);
			speedBtn.setText(to!string(round(70 * pow(1.3f, GameScene.speedMod))) ~ "$", 0.4f);
			updateMoney();
		}
	}

	void buyJump()
	{
		if (GameScene.money >= round(80 * pow(1.41f, GameScene.jumpMod)) && GameScene.jumpMod < 4)
		{
			GameScene.money -= round(80 * pow(1.41f, GameScene.jumpMod));
			GameScene.jumpMod++;
			jumpBar.set(GameScene.jumpMod);
			jumpBtn.setText(to!string(round(80 * pow(1.41f, GameScene.jumpMod))) ~ "$", 0.4f);
			updateMoney();
		}
	}

	void buySpecial()
	{
		if (GameScene.money >= round(500 * pow(1.8f, GameScene.special)) && GameScene.special < 2)
		{
			GameScene.money -= round(500 * pow(1.8f, GameScene.special));
			GameScene.special++;
			specialBar.set(GameScene.special);
			specialBtn.setText(to!string(round(500 * pow(1.8f, GameScene.special))) ~ "$", 0.4f);
			updateMoney();
		}
	}

	void buyMoney()
	{
		if (GameScene.money >= round(60 * pow(1.2f, GameScene.moneyMod)) && GameScene.moneyMod < 8)
		{
			GameScene.money -= round(60 * pow(1.2f, GameScene.moneyMod));
			GameScene.moneyMod++;
			moneyBar.set(GameScene.moneyMod);
			moneyBtn.setText(to!string(round(60 * pow(1.2f, GameScene.moneyMod))) ~ "$", 0.4f);
			updateMoney();
		}
	}

	void updateMoney()
	{
		money.set("$: " ~ to!string(GameScene.money), 0.5f);
		moneyAdd.position = vec2(50 + money.textWidth, 25);
	}

	Button addButton(string text, float textScale, vec2 pos, vec2 size, void delegate() click)
	{
		Button button = new Button(text, textScale);
		button.position = pos;
		button.setSize(size);

		button.connect(click);

		ui ~= button;
		return button;
	}

	Text addText(string text, float textScale, vec2 pos, vec4 color)
	{
		Text txt = new Text(text, textScale);
		txt.position = pos;
		txt.color	 = color;

		ui ~= txt;
		return txt;
	}

	BuyBar addBuy(int init, int max, vec2 pos)
	{
		BuyBar bar = new BuyBar(_texture.buyBarBack, _texture.buyBar, max);
		bar.set(init);
		bar.position = pos;

		ui ~= bar;
		return bar;
	}

	void replay()
	{
		_next = new GameScene(_texture);
	}

	@property TextureManager texture()
	{
		return _texture;
	}

	void onEvent(Event event)
	{
		foreach (elem; ui)
		{
			if (cast(Button) elem)
				(cast(Button) elem).onEvent(event);
		}

		if (event.type == Event.Type.KeyReleased)
		{
			if (event.key == SDLK_RETURN)
			{
				replay();
			}
		}
	}

	void update(float delta)
	{
	}

	void draw(IRenderTarget target)
	{
		target.clear(0.9803f, 0.9803f, 0.9803f);

		foreach (elem; ui)
			target.draw(elem);
	}

	IScene getNext()
	{
		return _next;
	}
}
