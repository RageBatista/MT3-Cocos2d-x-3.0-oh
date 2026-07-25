require "utils.tableutil"
SOffTitle = {}
SOffTitle.__index = SOffTitle



SOffTitle.PROTOCOL_TYPE = 798438

function SOffTitle.Create()
	print("enter SOffTitle create")
	return SOffTitle:new()
end
function SOffTitle:new()
	local self = {}
	setmetatable(self, SOffTitle)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SOffTitle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOffTitle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SOffTitle:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SOffTitle
