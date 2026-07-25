require "utils.tableutil"
SStepSpace = {}
SStepSpace.__index = SStepSpace



SStepSpace.PROTOCOL_TYPE = 806644

function SStepSpace.Create()
	print("enter SStepSpace create")
	return SStepSpace:new()
end
function SStepSpace:new()
	local self = {}
	setmetatable(self, SStepSpace)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SStepSpace:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SStepSpace:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.result)
	return _os_
end

function SStepSpace:unmarshal(_os_)
	self.result = _os_:unmarshal_char()
	return _os_
end

return SStepSpace
