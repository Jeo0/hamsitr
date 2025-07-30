// MouseDetection.cs
using Godot;
using Godot.Collections;

public partial class MouseDetection : Node
{
	// Put your interactive nodes on this layer; adjust in the editor or via code.
	[Export] public uint ClickableCollisionMask = 1u << 0;
	[Export] public float CheckIntervalSec = 0.05f; // 20 Hz

	private ApiManager _api;
	private bool _clickthrough = true;
	private double _accum;

	public override void _Ready()
	{
		_api = GetNode<ApiManager>("/root/ApiManager");
		_api.SetClickThrough(true);
	}

	public override void _PhysicsProcess(double delta)
	{
		_accum += delta;
		if (_accum < CheckIntervalSec)
			return;
		_accum = 0.0;

		// Screen-space mouse pos in the main Canvas
		Vector2 mouse = GetViewport().GetMousePosition();

		var space = GetViewport().World2D.DirectSpaceState;
		var pp = new PhysicsPointQueryParameters2D
		{
			Position = mouse,
			CollisionMask = ClickableCollisionMask,
			CollideWithAreas = true,
			CollideWithBodies = true
		};

		// Ask for just one hit — we only care if *anything* is there.
		Array<Dictionary> results = space.IntersectPoint(pp, 1);
		bool clickable = results.Count > 0;

		// Only toggle the OS window flag if state changes
		if (clickable == _clickthrough) // remember: clickthrough = !clickable
		{
			_clickthrough = !clickable;
			_api.SetClickThrough(_clickthrough);
		}
	}

	public override void _Input(InputEvent e)
	{
		// Optional: on mouse motion, force a check next physics step for snappier feel
		if (e is InputEventMouseMotion)
			_accum = CheckIntervalSec;
	}
}

/* // previous

using Godot;

public partial class MouseDetection : Node
{
	
	// Autoloaded
	
	private ApiManager _api;

	public override void _Ready()
	{
		_api = GetNode<ApiManager>("/root/ApiManager");
		
		// initializing as click-through
		_api.SetClickThrough(true);
	}
	
	// it is better to detect the pixels only when rendered, so PhysicsProcess is recommended
	// also can throttle the detection every few frames is possible
	public override void _PhysicsProcess(double delta)
	{
		DetectPassthrough();
	}

	
	// Detection of what color is the pixel under the mouse cursor, based on the viewport texture
	// This can become expensive if done every frame and in more complex scenes.
	// We will use this to determine whether the window should be clickable or not
	// You can choose any other method of detection!
	private void DetectPassthrough()
	{
		Viewport viewport = GetViewport();
		
		Image img = viewport.GetTexture().GetImage();
		Rect2 rect = viewport.GetVisibleRect();
		
		// Getting the mouse position in the viewport
		Vector2 mousePosition = viewport.GetMousePosition();
		int viewX = (int) ((int)mousePosition.X + rect.Position.X);
		int viewY = (int) ((int)mousePosition.Y + rect.Position.Y);

		// Getting the mouse position relative to the image (image will be the size of the window)
		int x = (int)(img.GetSize().X * viewX / rect.Size.X);
		int y = (int)(img.GetSize().Y * viewY / rect.Size.Y);

		// Getting the pixel at the mouse position coordinates
		if (x < img.GetSize().X && y < img.GetSize().Y)
		{
			Color pixel = img.GetPixel(x, y);
			SetClickability(pixel.A > 0.5f); 
		}

		// Very important to dispose the rendered image or will bloat memory !!!!!
		img.Dispose();
	}
	
	// instead of calling the API every frame, we check if the state is changed and then call it if necessary
	private bool _clickthrough = true;
	private void SetClickability(bool clickable)
	{
		if (clickable != _clickthrough)
		{
			_clickthrough = clickable;
			// clickthrough means NOT clickable
			_api.SetClickThrough(!clickable);
		}
	}
}
*/
