require "utils.tableutil"
CGetGoodLocksInfo = {}
CGetGoodLocksInfo.__index = CGetGoodLocksInfo



CGetGoodLocksInfo.PROTOCOL_TYPE = 786580

function CGetGoodLocksInfo.Create()
	print("enter CGetGoodLocksInfo create")
	return CGetGoodLocksInfo:new()
end
function CGetGoodLocksInfo:new()
	local self = {}
	setmetatable(self, CGetGoodLocksInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetGoodLocksInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetGoodLocksInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetGoodLocksInfo:unmarshal(_os_)
	return _os_
end

return CGetGoodLocksInfo
