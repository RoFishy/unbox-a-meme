local Log = {}

function Log.CreateLogFunction(Name: string, logFn: (...string) -> ())
	return function(...: any)
		local modulePath = debug.info(2, "s")
		local moduleName = modulePath:match("[^.]+$")

		logFn(`[{moduleName}][{Name}]:`, ...)
	end
end

Log.Debug = Log.CreateLogFunction("Debug", print)
Log.Info = Log.CreateLogFunction("Info", print)
Log.Warn = Log.CreateLogFunction("Warning", warn)
Log.Error = Log.CreateLogFunction("Error", function(message, ...)
	error(
		`Traceback: \n\n                {message} {...}\n\n                ------------------------------------------------`
	)
end)

return Log
