require "utils.tableutil"
CGetHuoBanList = {}
CGetHuoBanList.__index = CGetHuoBanList



CGetHuoBanList.PROTOCOL_TYPE = 818844

function CGetHuoBanList.Create()
	print("enter CGetHuoBanList create")
	return CGetHuoBanList:new()
end
function CGetHuoBanList:new()
	local self = {}
	setmetatable(self, CGetHuoBanList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetHuoBanList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetHuoBanList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetHuoBanList:unmarshal(_os_)
	return _os_
end

return CGetHuoBanList
