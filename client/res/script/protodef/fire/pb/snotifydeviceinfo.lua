require "utils.tableutil"
SNotifyDeviceInfo = {}
SNotifyDeviceInfo.__index = SNotifyDeviceInfo



SNotifyDeviceInfo.PROTOCOL_TYPE = 786515

function SNotifyDeviceInfo.Create()
	print("enter SNotifyDeviceInfo create")
	return SNotifyDeviceInfo:new()
end
function SNotifyDeviceInfo:new()
	local self = {}
	setmetatable(self, SNotifyDeviceInfo)
	self.type = self.PROTOCOL_TYPE
	self.ip = "" 

	return self
end
function SNotifyDeviceInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyDeviceInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.ip)
	return _os_
end

function SNotifyDeviceInfo:unmarshal(_os_)
	self.ip = _os_:unmarshal_wstring(self.ip)
	return _os_
end

return SNotifyDeviceInfo
