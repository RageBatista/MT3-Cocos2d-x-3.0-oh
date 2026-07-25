require "utils.tableutil"
SPetGossip = {}
SPetGossip.__index = SPetGossip



SPetGossip.PROTOCOL_TYPE = 788453

function SPetGossip.Create()
	print("enter SPetGossip create")
	return SPetGossip:new()
end
function SPetGossip:new()
	local self = {}
	setmetatable(self, SPetGossip)
	self.type = self.PROTOCOL_TYPE
	self.battleid = 0
	self.chatindex = 0

	return self
end
function SPetGossip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetGossip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.battleid)
	_os_:marshal_int32(self.chatindex)
	return _os_
end

function SPetGossip:unmarshal(_os_)
	self.battleid = _os_:unmarshal_int32()
	self.chatindex = _os_:unmarshal_int32()
	return _os_
end

return SPetGossip
