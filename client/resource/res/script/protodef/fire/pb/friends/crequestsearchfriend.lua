require "utils.tableutil"
CRequestSearchFriend = {}
CRequestSearchFriend.__index = CRequestSearchFriend



CRequestSearchFriend.PROTOCOL_TYPE = 806570

function CRequestSearchFriend.Create()
	print("enter CRequestSearchFriend create")
	return CRequestSearchFriend:new()
end
function CRequestSearchFriend:new()
	local self = {}
	setmetatable(self, CRequestSearchFriend)
	self.type = self.PROTOCOL_TYPE
	self.roleid = "" 

	return self
end
function CRequestSearchFriend:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSearchFriend:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.roleid)
	return _os_
end

function CRequestSearchFriend:unmarshal(_os_)
	self.roleid = _os_:unmarshal_wstring(self.roleid)
	return _os_
end

return CRequestSearchFriend
