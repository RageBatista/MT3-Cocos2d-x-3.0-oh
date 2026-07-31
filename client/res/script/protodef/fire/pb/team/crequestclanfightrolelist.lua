require "utils.tableutil"
CRequestClanFightRoleList = {}
CRequestClanFightRoleList.__index = CRequestClanFightRoleList



CRequestClanFightRoleList.PROTOCOL_TYPE = 794559

function CRequestClanFightRoleList.Create()
	print("enter CRequestClanFightRoleList create")
	return CRequestClanFightRoleList:new()
end
function CRequestClanFightRoleList:new()
	local self = {}
	setmetatable(self, CRequestClanFightRoleList)
	self.type = self.PROTOCOL_TYPE
	self.isfresh = 0
	self.start = 0
	self.num = 0

	return self
end
function CRequestClanFightRoleList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestClanFightRoleList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.isfresh)
	_os_:marshal_int64(self.start)
	_os_:marshal_int32(self.num)
	return _os_
end

function CRequestClanFightRoleList:unmarshal(_os_)
	self.isfresh = _os_:unmarshal_int32()
	self.start = _os_:unmarshal_int64()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return CRequestClanFightRoleList
