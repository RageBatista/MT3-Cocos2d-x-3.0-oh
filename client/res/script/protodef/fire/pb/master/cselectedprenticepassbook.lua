require "utils.tableutil"
CSelectedPrenticePassBook = {}
CSelectedPrenticePassBook.__index = CSelectedPrenticePassBook



CSelectedPrenticePassBook.PROTOCOL_TYPE = 816454

function CSelectedPrenticePassBook.Create()
	print("enter CSelectedPrenticePassBook create")
	return CSelectedPrenticePassBook:new()
end
function CSelectedPrenticePassBook:new()
	local self = {}
	setmetatable(self, CSelectedPrenticePassBook)
	self.type = self.PROTOCOL_TYPE
	self.prenticeid = 0
	self.itemkey = 0

	return self
end
function CSelectedPrenticePassBook:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSelectedPrenticePassBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.prenticeid)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CSelectedPrenticePassBook:unmarshal(_os_)
	self.prenticeid = _os_:unmarshal_int64()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CSelectedPrenticePassBook
