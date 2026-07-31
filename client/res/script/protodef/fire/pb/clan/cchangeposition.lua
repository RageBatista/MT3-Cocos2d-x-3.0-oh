require "utils.tableutil"
CChangePosition = {}
CChangePosition.__index = CChangePosition



CChangePosition.PROTOCOL_TYPE = 808464

function CChangePosition.Create()
	print("enter CChangePosition create")
	return CChangePosition:new()
end
function CChangePosition:new()
	local self = {}
	setmetatable(self, CChangePosition)
	self.type = self.PROTOCOL_TYPE
	self.memberroleid = 0
	self.position = 0

	return self
end
function CChangePosition:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangePosition:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberroleid)
	_os_:marshal_int32(self.position)
	return _os_
end

function CChangePosition:unmarshal(_os_)
	self.memberroleid = _os_:unmarshal_int64()
	self.position = _os_:unmarshal_int32()
	return _os_
end

return CChangePosition
