require "utils.tableutil"
CGetPackInfo = {}
CGetPackInfo.__index = CGetPackInfo



CGetPackInfo.PROTOCOL_TYPE = 787442

function CGetPackInfo.Create()
	print("enter CGetPackInfo create")
	return CGetPackInfo:new()
end
function CGetPackInfo:new()
	local self = {}
	setmetatable(self, CGetPackInfo)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.npcid = 0

	return self
end
function CGetPackInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetPackInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int64(self.npcid)
	return _os_
end

function CGetPackInfo:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.npcid = _os_:unmarshal_int64()
	return _os_
end

return CGetPackInfo
