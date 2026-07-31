require "utils.tableutil"
CRequestMasterPrenticeList = {}
CRequestMasterPrenticeList.__index = CRequestMasterPrenticeList



CRequestMasterPrenticeList.PROTOCOL_TYPE = 816468

function CRequestMasterPrenticeList.Create()
	print("enter CRequestMasterPrenticeList create")
	return CRequestMasterPrenticeList:new()
end
function CRequestMasterPrenticeList:new()
	local self = {}
	setmetatable(self, CRequestMasterPrenticeList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestMasterPrenticeList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestMasterPrenticeList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestMasterPrenticeList:unmarshal(_os_)
	return _os_
end

return CRequestMasterPrenticeList
