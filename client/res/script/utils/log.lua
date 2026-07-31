

function LogErr(msg)
	if core.Errors > core.GetCoreLogger():getLoggingLevel() then return end
	core.GetCoreLogger():logLuaEvent(core.Errors,msg)
end

function LogWar(msg)
	if core.Warnings > core.GetCoreLogger():getLoggingLevel() then return end
	core.GetCoreLogger():logLuaEvent(core.Warnings,msg)
end

function LogStd(msg)
	if core.Standard > core.GetCoreLogger():getLoggingLevel() then return end
	core.GetCoreLogger():logLuaEvent(core.Standard,msg)
end

function LogInfo(msg)
	if core.Informative > core.GetCoreLogger():getLoggingLevel() then return end
	core.GetCoreLogger():logLuaEvent(core.Informative,msg)
end

function LogInsane(msg)
	if core.Insane> core.GetCoreLogger():getLoggingLevel() then return end
	core.GetCoreLogger():logLuaEvent(core.Insane,msg)
end

function LogCustom(level,msg)
	core.GetCoreLogger():logLuaEventInt(level,msg)
end

function LogPass(level,msg)
	core.GetCoreLogger():AddPassLevel(level,"")
	core.GetCoreLogger():logLuaEventInt(level,msg)
end

function LogInsaneFormat(format, ...)
	local msg = string.format(format, ...)
	print(msg)
end

function LogFlurryEvent(msg)
	core.Logger:flurryEvent(msg)
end
