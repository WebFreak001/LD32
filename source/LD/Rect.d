module LD.Rect;

import D2D;

class RepeatedRectangle : Shape
{
protected:
	Mesh _mesh;
	vec2 size, repeat, start;

public:
	this()
	{
		_mesh = new Mesh();
		setSize(vec2(1, 1));
		setRepeat(vec2(1, 1));
		setRepeatStart(vec2(0, 0));
		create();
	}

	void setSize(const vec2 size)
	{
		this.size = size;
	}

	void setRepeat(const vec2 repeat)
	{
		this.repeat = repeat;
	}

	void setRepeatStart(const vec2 start)
	{
		this.start = start;
	}

	void create()
	{
		_mesh.dispose();
		_mesh = new Mesh();
		_mesh.addVertices([vec3(0, 0, 0), vec3(size.x, 0, 0), vec3(size.x, size.y, 0), vec3(0, size.y, 0)]);
		_mesh.addTexCoords([vec2(start.x, start.y), vec2(repeat.x, start.y), vec2(repeat.x, repeat.y), vec2(start.x, repeat.y)]);
		_mesh.addIndices([0, 1, 2, 0, 2, 3]);
		_mesh.create();
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null)
	{
		matrixStack.push();
		matrixStack.top = matrixStack.top * transform;
		if (texture !is null)
			texture.bind(0);
		target.draw(_mesh, shader);
		matrixStack.pop();
	}
}

class Rect
{
public:
	static RepeatedRectangle createRepeatOff(Texture tex, vec2 pos, vec2 size, vec2 repeat, vec2 start)
	{
		auto shape = new RepeatedRectangle();
		shape.texture  = tex;
		shape.position = pos;
		shape.setSize(size);
		shape.setRepeat(repeat);
		shape.setRepeatStart(start);
		shape.create();
		return shape;
	}

	static RepeatedRectangle createRepeat(Texture tex, vec2 pos, vec2 size, vec2 repeat)
	{
		auto shape = new RepeatedRectangle();
		shape.texture  = tex;
		shape.position = pos;
		shape.setSize(size);
		shape.setRepeat(repeat);
		shape.create();
		return shape;
	}

	static RectangleShape create(Texture tex, vec2 pos, vec2 size)
	{
		auto shape = new RectangleShape();
		shape.texture  = tex;
		shape.position = pos;
		shape.setSize(size);
		return shape;
	}
}
