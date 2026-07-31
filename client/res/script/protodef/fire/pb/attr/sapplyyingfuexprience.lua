require "utils.tableutil"
SApplyYingFuExprience = {}
SApplyYingFuExprience.__index = SApplyYingFuExprience



SApplyYingFuExprience.PROTOCOL_TYPE = 799439

function SApplyYingFuExprience.Create()
	print("enter SApplyYingFuExprience create")
	return SApplyYingFuExprience:new()
end
function SApplyYingFuExprience:new()
	local self = {}
	setmetatable(self, SApplyYingFuExprience)
	self.type = self.PROTOCOL_TYPE
	self.exprience = 0

	return self
end
function SApplyYingFuExprience:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SApplyYingFuExprience:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.exprience)
	return _os_
end

function SApplyYingFuExprience:unmarshal(_os_)
	self.exprience = _os_:unmarshal_int64()
	return _os_
end

return SApplyYingFuExprience
