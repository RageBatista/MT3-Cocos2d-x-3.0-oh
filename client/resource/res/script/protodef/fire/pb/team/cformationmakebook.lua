require "utils.tableutil"
CFormationMakeBook = {}
CFormationMakeBook.__index = CFormationMakeBook



CFormationMakeBook.PROTOCOL_TYPE = 794552

function CFormationMakeBook.Create()
	print("enter CFormationMakeBook create")
	return CFormationMakeBook:new()
end
function CFormationMakeBook:new()
	local self = {}
	setmetatable(self, CFormationMakeBook)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CFormationMakeBook:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFormationMakeBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CFormationMakeBook:unmarshal(_os_)
	return _os_
end

return CFormationMakeBook
