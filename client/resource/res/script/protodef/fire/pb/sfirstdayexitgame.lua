require "utils.tableutil"
SFirstDayExitGame = {}
SFirstDayExitGame.__index = SFirstDayExitGame



SFirstDayExitGame.PROTOCOL_TYPE = 786489

function SFirstDayExitGame.Create()
	print("enter SFirstDayExitGame create")
	return SFirstDayExitGame:new()
end
function SFirstDayExitGame:new()
	local self = {}
	setmetatable(self, SFirstDayExitGame)
	self.type = self.PROTOCOL_TYPE
	self.firstdayleftsecond = 0

	return self
end
function SFirstDayExitGame:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFirstDayExitGame:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.firstdayleftsecond)
	return _os_
end

function SFirstDayExitGame:unmarshal(_os_)
	self.firstdayleftsecond = _os_:unmarshal_int32()
	return _os_
end

return SFirstDayExitGame
