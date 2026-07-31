
function class(name)
	_G[name] = {classname = name}
	_G[name].__index = _G[name]
	_G[name].new = function()
		local ret = {}
		setmetatable(ret, _G[name])
		if ret.init then
			ret:init()
		end
		return ret
	end
	return _G[name]
end
