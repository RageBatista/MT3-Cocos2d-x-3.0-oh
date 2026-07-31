require "utils.tableutil"
SCanRequestAsMaster = {}
SCanRequestAsMaster.__index = SCanRequestAsMaster



SCanRequestAsMaster.PROTOCOL_TYPE = 816464

function SCanRequestAsMaster.Create()
	print("enter SCanRequestAsMaster create")
	return SCanRequestAsMaster:new()
end
function SCanRequestAsMaster:new()
	local self = {}
	setmetatable(self, SCanRequestAsMaster)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 

	return self
end
function SCanRequestAsMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCanRequestAsMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	return _os_
end

function SCanRequestAsMaster:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	return _os_
end

return SCanRequestAsMaster
