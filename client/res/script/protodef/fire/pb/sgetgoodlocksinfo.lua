require "utils.tableutil"
SGetGoodLocksInfo = {}
SGetGoodLocksInfo.__index = SGetGoodLocksInfo



SGetGoodLocksInfo.PROTOCOL_TYPE = 786581

function SGetGoodLocksInfo.Create()
	print("enter SGetGoodLocksInfo create")
	return SGetGoodLocksInfo:new()
end
function SGetGoodLocksInfo:new()
	local self = {}
	setmetatable(self, SGetGoodLocksInfo)
	self.type = self.PROTOCOL_TYPE
	self.password = "" 
	self.forcedelpdtime = 0
	self.forcedelendtime = 0
	self.isfistloginofday = 0
	self.errortimes = 0
	self.lockendtime = 0
	self.isopensafelock = 0

	return self
end
function SGetGoodLocksInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetGoodLocksInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.password)
	_os_:marshal_int64(self.forcedelpdtime)
	_os_:marshal_int64(self.forcedelendtime)
	_os_:marshal_char(self.isfistloginofday)
	_os_:marshal_char(self.errortimes)
	_os_:marshal_int64(self.lockendtime)
	_os_:marshal_char(self.isopensafelock)
	return _os_
end

function SGetGoodLocksInfo:unmarshal(_os_)
	self.password = _os_:unmarshal_wstring(self.password)
	self.forcedelpdtime = _os_:unmarshal_int64()
	self.forcedelendtime = _os_:unmarshal_int64()
	self.isfistloginofday = _os_:unmarshal_char()
	self.errortimes = _os_:unmarshal_char()
	self.lockendtime = _os_:unmarshal_int64()
	self.isopensafelock = _os_:unmarshal_char()
	return _os_
end

return SGetGoodLocksInfo
