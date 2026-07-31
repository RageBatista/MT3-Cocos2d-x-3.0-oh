require "utils.tableutil"
CSearchPrentice = {}
CSearchPrentice.__index = CSearchPrentice



CSearchPrentice.PROTOCOL_TYPE = 816446

function CSearchPrentice.Create()
	print("enter CSearchPrentice create")
	return CSearchPrentice:new()
end
function CSearchPrentice:new()
	local self = {}
	setmetatable(self, CSearchPrentice)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0

	return self
end
function CSearchPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSearchPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	return _os_
end

function CSearchPrentice:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	return _os_
end

return CSearchPrentice
