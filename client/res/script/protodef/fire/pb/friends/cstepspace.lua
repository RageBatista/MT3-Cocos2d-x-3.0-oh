require "utils.tableutil"
CStepSpace = {}
CStepSpace.__index = CStepSpace



CStepSpace.PROTOCOL_TYPE = 806643

function CStepSpace.Create()
	print("enter CStepSpace create")
	return CStepSpace:new()
end
function CStepSpace:new()
	local self = {}
	setmetatable(self, CStepSpace)
	self.type = self.PROTOCOL_TYPE
	self.spaceroleid = 0

	return self
end
function CStepSpace:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CStepSpace:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.spaceroleid)
	return _os_
end

function CStepSpace:unmarshal(_os_)
	self.spaceroleid = _os_:unmarshal_int64()
	return _os_
end

return CStepSpace
