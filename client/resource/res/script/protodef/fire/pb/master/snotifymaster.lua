require "utils.tableutil"
SNotifyMaster = {}
SNotifyMaster.__index = SNotifyMaster



SNotifyMaster.PROTOCOL_TYPE = 816436

function SNotifyMaster.Create()
	print("enter SNotifyMaster create")
	return SNotifyMaster:new()
end
function SNotifyMaster:new()
	local self = {}
	setmetatable(self, SNotifyMaster)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0

	return self
end
function SNotifyMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)
	return _os_
end

function SNotifyMaster:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return SNotifyMaster
