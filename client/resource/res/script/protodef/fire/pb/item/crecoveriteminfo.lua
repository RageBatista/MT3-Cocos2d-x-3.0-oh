require "utils.tableutil"
CRecoverItemInfo = {}
CRecoverItemInfo.__index = CRecoverItemInfo



CRecoverItemInfo.PROTOCOL_TYPE = 787797

function CRecoverItemInfo.Create()
	print("enter CRecoverItemInfo create")
	return CRecoverItemInfo:new()
end
function CRecoverItemInfo:new()
	local self = {}
	setmetatable(self, CRecoverItemInfo)
	self.type = self.PROTOCOL_TYPE
	self.uniqid = 0

	return self
end
function CRecoverItemInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRecoverItemInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniqid)
	return _os_
end

function CRecoverItemInfo:unmarshal(_os_)
	self.uniqid = _os_:unmarshal_int64()
	return _os_
end

return CRecoverItemInfo
