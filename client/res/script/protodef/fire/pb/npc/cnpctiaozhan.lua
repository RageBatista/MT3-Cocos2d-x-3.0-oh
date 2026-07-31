require "utils.tableutil"
CNpctiaozhan = {}
CNpctiaozhan.__index = CNpctiaozhan



CNpctiaozhan.PROTOCOL_TYPE = 800098

function CNpctiaozhan.Create()
	print("enter CNpctiaozhan create")
	return CNpctiaozhan:new()
end
function CNpctiaozhan:new()
	local self = {}
	setmetatable(self, CNpctiaozhan)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.serviceid = 0

	return self
end
function CNpctiaozhan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CNpctiaozhan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.serviceid)
	return _os_
end

function CNpctiaozhan:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.serviceid = _os_:unmarshal_int32()
	return _os_
end

return CNpctiaozhan
