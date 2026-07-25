BINUtil = {}
BINUtil.__index = BINUtil

function BINUtil:new()
	local self = {}
	setmetatable(self, BINUtil)
	return self
end

function BINUtil:release()
	if self.file then
		self.file:Close()
		self.file = nil
	end
end

function BINUtil:init(filename)
	self.file = LJFM.LJFMF()
	if not self.file:Open(filename, LJFM.FM_EXCL, LJFM.FA_RDONLY) then
		self.file:Close()
		self.file = nil
		return false
	end
	return true
end

function BINUtil:Load_short()
	local ret =  0
	local val
	val,ret = LJFM.ShortValueFromTable(self.file, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_int()
	local ret =  0
	local val
	val,ret = LJFM.IntValueFromTable(self.file, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_long()
	local ret =  0
	local val
	val,ret = LJFM.LongValueFromTable(self.file, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_double()
	local ret =  0
	local val
	val,ret = LJFM.DoubleValueFromTable(self.file, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_bool()
	local ret =  0
	local val
	val,ret = LJFM.BoolValueFromTable(self.file, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_string()
	local ret =  0
	local val
	val,ret = LJFM.StringValueFromTable(self.file, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_Vint()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = LJFM.IntValueFromTable(self.file, ret)
	val._size = (size == -1 and 0 or size)
	function val:size()
		return self._size
	end
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_int(self.file, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vlong()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = LJFM.IntValueFromTable(self.file, ret)
	val._size = (size == -1 and 0 or size)
	function val:size()
		return self._size
	end
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_long(self.file, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vdouble()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = LJFM.IntValueFromTable(self.file, ret)
	val._size = (size == -1 and 0 or size)
	function val:size()
		return self._size
	end
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_double(self.file, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vbool()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = LJFM.IntValueFromTable(self.file, ret)
	val._size = (size == -1 and 0 or size)
	function val:size()
		return self._size
	end
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_bool(self.file, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vstring()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = LJFM.IntValueFromTable(self.file, ret)
	val._size = (size == -1 and 0 or size)
	function val:size()
		return self._size
	end
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_string(self.file, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

return BINUtil
