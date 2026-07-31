require "utils.tableutil"
CQueryRegData = {}
CQueryRegData.__index = CQueryRegData



CQueryRegData.PROTOCOL_TYPE = 810532

function CQueryRegData.Create()
	print("enter CQueryRegData create")
	return CQueryRegData:new()
end
function CQueryRegData:new()
	local self = {}
	setmetatable(self, CQueryRegData)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CQueryRegData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryRegData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CQueryRegData:unmarshal(_os_)
	return _os_
end

return CQueryRegData
