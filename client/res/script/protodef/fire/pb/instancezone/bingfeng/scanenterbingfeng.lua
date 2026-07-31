require "utils.tableutil"
SCanEnterBingFeng = {}
SCanEnterBingFeng.__index = SCanEnterBingFeng



SCanEnterBingFeng.PROTOCOL_TYPE = 804562

function SCanEnterBingFeng.Create()
	print("enter SCanEnterBingFeng create")
	return SCanEnterBingFeng:new()
end
function SCanEnterBingFeng:new()
	local self = {}
	setmetatable(self, SCanEnterBingFeng)
	self.type = self.PROTOCOL_TYPE
	self.finish = 0

	return self
end
function SCanEnterBingFeng:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCanEnterBingFeng:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.finish)
	return _os_
end

function SCanEnterBingFeng:unmarshal(_os_)
	self.finish = _os_:unmarshal_int32()
	return _os_
end

return SCanEnterBingFeng
