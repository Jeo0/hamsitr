// ApiManager.cs
using Godot;
using System;
using System.Runtime.InteropServices;

public partial class ApiManager : Node
{
	// WinAPI (64-bit safe)
	private const int GWL_EXSTYLE = -20;
	private const uint WS_EX_LAYERED = 0x00080000;
	private const uint WS_EX_TRANSPARENT = 0x00000020;

	[DllImport("user32.dll")]
	private static extern IntPtr GetActiveWindow();

	[DllImport("user32.dll", EntryPoint = "GetWindowLongPtrW")]
	private static extern IntPtr GetWindowLongPtr(IntPtr hWnd, int nIndex);

	[DllImport("user32.dll", EntryPoint = "SetWindowLongPtrW")]
	private static extern IntPtr SetWindowLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

	private IntPtr _hWnd;

	public override void _Ready()
	{
		// Use the current active window (your original approach).
		// This works well if the game window has focus when you start/toggle.
		_hWnd = GetActiveWindow();
		EnsureLayered();
	}

	private void EnsureLayered()
	{
		ulong style = (ulong)GetWindowLongPtr(_hWnd, GWL_EXSTYLE);
		if ((style & WS_EX_LAYERED) == 0)
		{
			style |= WS_EX_LAYERED;
			SetWindowLongPtr(_hWnd, GWL_EXSTYLE, (IntPtr)style);
		}
	}

	public void SetClickThrough(bool clickthrough)
	{
		ulong style = (ulong)GetWindowLongPtr(_hWnd, GWL_EXSTYLE);
		style |= WS_EX_LAYERED; // keep layered set at all times

		if (clickthrough)
			style |= WS_EX_TRANSPARENT;
		else
			style &= ~WS_EX_TRANSPARENT;

		SetWindowLongPtr(_hWnd, GWL_EXSTYLE, (IntPtr)style);
	}
}


/* // previous 
using Godot;

// Remember to include System and System.Runtime.InteropServices
using System;
using System.Runtime.InteropServices;

public partial class ApiManager : Node
{
	// Autoloaded
	
	// GetActiveWindow() retrieves the handle of the window. 
	[DllImport("user32.dll")]
	public static extern IntPtr GetActiveWindow();

	// SetWindowLong() modifies a specific flag value associated with a window.
	// We pass the window handle, the index of the property, and the flags the property will have
	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);
	
	// This is the index of the property we want to modify
	private const int GwlExStyle = -20;
	
	// The flags we want to set
	private const uint WsExLayered = 0x00080000;			// Makes the window "layered"
	private const uint WsExTransparent = 0x00000020;		// Makes the window "clickable through"
	// check https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles 

	// This is the variable containing the window handle
	private IntPtr _hWnd;

	public override void _Ready()
	{
		// We store the window handle
		_hWnd = GetActiveWindow();
		
		// We can set the properties already from here
		SetWindowLong(_hWnd, GwlExStyle, WsExLayered );
	}
	
	// This function sets the property of being clickable or not, we will call this function from the mouse detection 
	public void SetClickThrough(bool clickthrough)
	{
		if (clickthrough)
		{
			// We set the window as layered and click-through
			SetWindowLong(_hWnd, GwlExStyle,   WsExLayered | WsExTransparent);
		}
		else
		{
			// We only set the window as layered, so it will be clickable
			SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
		}
	}
	
	
  */
	
	/* What is a layered window? 
	 * In the Windows API, a layered window is a special type of window that offers several
	 * advantages over standard windows:
	 * 
	 * Transparency: Layered windows can be partially transparent, allowing the content of underlying windows
	 * to show through. This can be achieved using either color keying, where a specific color in the window
	 * is transparent, or alpha blending, where the window's opacity is specified for each pixel.
	 *
	 * Complex Shapes: Layered windows can have complex shapes that are not limited by rectangular regions.
	 * This is achieved by defining a custom region, allowing for more visually appealing or functional window designs.
	 *
	 * Animation: Layered windows can be animated smoothly without the visual artifacts
	 * that can occur with standard windows due to region updates. This is because the system automatically manages
	 * the composition of layered windows with underlying elements.
	 */
/* } */
