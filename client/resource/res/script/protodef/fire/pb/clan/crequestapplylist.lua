require "utils.tableutil"
CRequestApplyList = {}
CRequestApplyList.__index = CRequestApplyList



CRequestApplyList.PROTOCOL_TYPE = 808454

function CRequestApplyList.Create()
	print("enter CRequestApplyList create")
	return CRequestApplyList:new()
end
function CRequestApplyList:new()
	local self = {}
	setmetatable(self, CRequestApplyList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestApplyList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestApplyList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestApplyList:unmarshal(_os_)
	return _os_
end

return CRequestApplyList
