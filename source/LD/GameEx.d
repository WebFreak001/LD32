module LD.GameEx;

import D2D;

import std.datetime;

class GameEx
{
private:
	int		  _width  = 800, _height = 480;
	Bitmap	  _icon	  = null;
	Window	  _window = null;
	string	  _title  = "Game";
	int		  _fps	  = 60;
	StopWatch _stopwatch;
	uint	  _flags = 0;

protected:
	ShaderProgram postShader = null;

	@property ref uint windowFlags()
	{
		return _flags;
	}

	@property ref int windowWidth()
	{
		return _width;
	}

	@property ref int windowHeight()
	{
		return _height;
	}

	@property ref Bitmap windowIcon()
	{
		return _icon;
	}

	@property ref string windowTitle()
	{
		return _title;
	}

	@property ref int maxFPS()
	{
		return _fps;
	}

	@property Window window()
	{
		return _window;
	}

	abstract void init()
	{
	}

	abstract void load()
	{
	}

	abstract void update(float delta)
	{
	}

	abstract void draw()
	{
	}

	void onEvent(Event event)
	{
	}
public:
	void run()
	{
		init();

		if (_flags == 0)
			_flags = WindowFlags.Default;

		_window = new Window(_width, _height, _title, _flags);

		FPSLimiter limiter;
		if (_fps > 0)
			limiter = new FPSLimiter(_fps);

		load();

		Event		 event;
		TickDuration delta;
		while (_window.open)
		{
			_stopwatch.start();
			while (_window.pollEvent(event))
			{
				if (event.type == Event.Type.Quit)
					_window.close();
				else
					onEvent(event);
			}

			update(delta.to!("seconds", float));

			draw();

			_window.display(postShader);

			if (limiter !is null)
				limiter.wait();

			_stopwatch.stop();
			delta = _stopwatch.peek();
			_stopwatch.reset();
		}
	}
}
