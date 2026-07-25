require "utils.tableutil"
CGetClanFightList = {}
CGetClanFightList.__index = CGetClanFightList



CGetClanFightList.PROTOCOL_TYPE = 808532

function CGetClanFightList.Create()
	print("enter CGetClanFightList create")
	return CGetClanFightList:new()
end
function CGetClanFightList:new()
	local self = {}
	setmetatable(self, CGetClanFightList)
	self.type = self.PROTOCOL_TYPE
	self.whichweek = 0
	self.which = 0

	return self
end
function CGetClanFightList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetClanFightList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.whichweek)
	_os_:marshal_int32(self.which)
	return _os_
end

function CGetClanFightList:unmarshal(_os_)
	self.whichweek = _os_:unmarshal_int32()
	self.which = _os_:unmarshal_int32()
	return _os_
end

return CGetClanFightList
