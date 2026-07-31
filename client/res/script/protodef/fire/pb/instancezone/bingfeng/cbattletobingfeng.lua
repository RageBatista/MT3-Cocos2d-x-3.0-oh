require "utils.tableutil"
CBattletoBingFeng = {}
CBattletoBingFeng.__index = CBattletoBingFeng



CBattletoBingFeng.PROTOCOL_TYPE = 804567

function CBattletoBingFeng.Create()
	print("enter CBattletoBingFeng create")
	return CBattletoBingFeng:new()
end
function CBattletoBingFeng:new()
	local self = {}
	setmetatable(self, CBattletoBingFeng)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.npcid = 0

	return self
end
function CBattletoBingFeng:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBattletoBingFeng:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.npcid)
	return _os_
end

function CBattletoBingFeng:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.npcid = _os_:unmarshal_int32()
	return _os_
end

return CBattletoBingFeng
