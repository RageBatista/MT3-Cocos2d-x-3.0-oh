require "utils.tableutil"
SRecoverItemInfo = {}
SRecoverItemInfo.__index = SRecoverItemInfo



SRecoverItemInfo.PROTOCOL_TYPE = 787798

function SRecoverItemInfo.Create()
	print("enter SRecoverItemInfo create")
	return SRecoverItemInfo:new()
end
function SRecoverItemInfo:new()
	local self = {}
	setmetatable(self, SRecoverItemInfo)
	self.type = self.PROTOCOL_TYPE
	self.uniqid = 0
	self.tips = FireNet.Octets() 

	return self
end
function SRecoverItemInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRecoverItemInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniqid)
	_os_: marshal_octets(self.tips)
	return _os_
end

function SRecoverItemInfo:unmarshal(_os_)
	self.uniqid = _os_:unmarshal_int64()
	_os_:unmarshal_octets(self.tips)
	return _os_
end

return SRecoverItemInfo
