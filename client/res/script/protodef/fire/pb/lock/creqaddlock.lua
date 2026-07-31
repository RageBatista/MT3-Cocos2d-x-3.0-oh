require "utils.tableutil"
CReqAddLock = {}
CReqAddLock.__index = CReqAddLock



CReqAddLock.PROTOCOL_TYPE = 818934

function CReqAddLock.Create()
	print("enter CReqAddLock create")
	return CReqAddLock:new()
end
function CReqAddLock:new()
	local self = {}
	setmetatable(self, CReqAddLock)
	self.type = self.PROTOCOL_TYPE
	self.password = "" 

	return self
end
function CReqAddLock:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqAddLock:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.password)
	return _os_
end

function CReqAddLock:unmarshal(_os_)
	self.password = _os_:unmarshal_wstring(self.password)
	return _os_
end

return CReqAddLock
