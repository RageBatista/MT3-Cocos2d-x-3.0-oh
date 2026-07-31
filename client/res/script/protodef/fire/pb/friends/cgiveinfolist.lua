require "utils.tableutil"
CGiveInfoList = {}
CGiveInfoList.__index = CGiveInfoList



CGiveInfoList.PROTOCOL_TYPE = 806633

function CGiveInfoList.Create()
	print("enter CGiveInfoList create")
	return CGiveInfoList:new()
end
function CGiveInfoList:new()
	local self = {}
	setmetatable(self, CGiveInfoList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGiveInfoList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGiveInfoList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGiveInfoList:unmarshal(_os_)
	return _os_
end

return CGiveInfoList
