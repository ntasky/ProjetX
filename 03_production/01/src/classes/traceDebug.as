package
{
	import com.zeroun.components.debugwindow.DebugWindow;

	public function traceDebug (... args) : void
	{
		DebugWindow.traceToDebugWindow(args.join(DebugWindow.ARGS_DELIMITER));
	}
}