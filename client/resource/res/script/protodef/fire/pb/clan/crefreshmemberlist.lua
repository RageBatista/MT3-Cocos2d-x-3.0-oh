require "utils.tableutil"
CRefreshMemberList = {}
CRefreshMemberList.__index = CRefreshMemberList



CRefreshMemberList.PROTOCOL_TYPE = 808492

function CRefreshMemberList.Create()
	print("enter CRefreshMemberList create")
	return CRefreshMemberList:new()
end
function CRefreshMemberList:new()
	local self = {}
	setmetatable(self, CRefreshMemberList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRefreshMemberList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRefreshMemberList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRefreshMemberList:unmarshal(_os_)
	return _os_
end

return CRefreshMemberList
