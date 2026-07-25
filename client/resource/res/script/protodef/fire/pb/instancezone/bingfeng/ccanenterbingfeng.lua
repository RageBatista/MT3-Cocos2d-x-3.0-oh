require "utils.tableutil"
CCanEnterBingFeng = {}
CCanEnterBingFeng.__index = CCanEnterBingFeng



CCanEnterBingFeng.PROTOCOL_TYPE = 804557

function CCanEnterBingFeng.Create()
	print("enter CCanEnterBingFeng create")
	return CCanEnterBingFeng:new()
end
function CCanEnterBingFeng:new()
	local self = {}
	setmetatable(self, CCanEnterBingFeng)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CCanEnterBingFeng:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCanEnterBingFeng:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CCanEnterBingFeng:unmarshal(_os_)
	return _os_
end

return CCanEnterBingFeng
