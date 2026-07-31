require "utils.tableutil"
SNotifyAppMaster = {}
SNotifyAppMaster.__index = SNotifyAppMaster



SNotifyAppMaster.PROTOCOL_TYPE = 816484

function SNotifyAppMaster.Create()
	print("enter SNotifyAppMaster create")
	return SNotifyAppMaster:new()
end
function SNotifyAppMaster:new()
	local self = {}
	setmetatable(self, SNotifyAppMaster)
	self.type = self.PROTOCOL_TYPE
	self.mastername = "" 

	return self
end
function SNotifyAppMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyAppMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.mastername)
	return _os_
end

function SNotifyAppMaster:unmarshal(_os_)
	self.mastername = _os_:unmarshal_wstring(self.mastername)
	return _os_
end

return SNotifyAppMaster
