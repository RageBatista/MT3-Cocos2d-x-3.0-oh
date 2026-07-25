require "utils.tableutil"
SNotifyDismissMaster = {}
SNotifyDismissMaster.__index = SNotifyDismissMaster



SNotifyDismissMaster.PROTOCOL_TYPE = 816478

function SNotifyDismissMaster.Create()
	print("enter SNotifyDismissMaster create")
	return SNotifyDismissMaster:new()
end
function SNotifyDismissMaster:new()
	local self = {}
	setmetatable(self, SNotifyDismissMaster)
	self.type = self.PROTOCOL_TYPE
	self.mastername = "" 

	return self
end
function SNotifyDismissMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyDismissMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.mastername)
	return _os_
end

function SNotifyDismissMaster:unmarshal(_os_)
	self.mastername = _os_:unmarshal_wstring(self.mastername)
	return _os_
end

return SNotifyDismissMaster
