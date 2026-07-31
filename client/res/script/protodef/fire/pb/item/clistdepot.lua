require "utils.tableutil"
CListDepot = {}
CListDepot.__index = CListDepot



CListDepot.PROTOCOL_TYPE = 787762

function CListDepot.Create()
	print("enter CListDepot create")
	return CListDepot:new()
end
function CListDepot:new()
	local self = {}
	setmetatable(self, CListDepot)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0

	return self
end
function CListDepot:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CListDepot:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	return _os_
end

function CListDepot:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	return _os_
end

return CListDepot
