require "utils.tableutil"
CShouxiShape = {}
CShouxiShape.__index = CShouxiShape



CShouxiShape.PROTOCOL_TYPE = 810439

function CShouxiShape.Create()
	print("enter CShouxiShape create")
	return CShouxiShape:new()
end
function CShouxiShape:new()
	local self = {}
	setmetatable(self, CShouxiShape)
	self.type = self.PROTOCOL_TYPE
	self.shouxikey = 0

	return self
end
function CShouxiShape:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShouxiShape:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.shouxikey)
	return _os_
end

function CShouxiShape:unmarshal(_os_)
	self.shouxikey = _os_:unmarshal_int64()
	return _os_
end

return CShouxiShape
