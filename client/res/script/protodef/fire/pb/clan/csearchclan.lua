require "utils.tableutil"
CSearchClan = {}
CSearchClan.__index = CSearchClan



CSearchClan.PROTOCOL_TYPE = 808486

function CSearchClan.Create()
	print("enter CSearchClan create")
	return CSearchClan:new()
end
function CSearchClan:new()
	local self = {}
	setmetatable(self, CSearchClan)
	self.type = self.PROTOCOL_TYPE
	self.clanid = 0

	return self
end
function CSearchClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSearchClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid)
	return _os_
end

function CSearchClan:unmarshal(_os_)
	self.clanid = _os_:unmarshal_int64()
	return _os_
end

return CSearchClan
