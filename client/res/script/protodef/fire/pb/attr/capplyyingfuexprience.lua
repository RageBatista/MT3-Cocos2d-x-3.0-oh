require "utils.tableutil"
CApplyYingFuExprience = {}
CApplyYingFuExprience.__index = CApplyYingFuExprience



CApplyYingFuExprience.PROTOCOL_TYPE = 799438

function CApplyYingFuExprience.Create()
	print("enter CApplyYingFuExprience create")
	return CApplyYingFuExprience:new()
end
function CApplyYingFuExprience:new()
	local self = {}
	setmetatable(self, CApplyYingFuExprience)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CApplyYingFuExprience:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CApplyYingFuExprience:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CApplyYingFuExprience:unmarshal(_os_)
	return _os_
end

return CApplyYingFuExprience
