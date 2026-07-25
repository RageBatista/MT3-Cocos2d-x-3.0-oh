require "utils.tableutil"
CPetLearnInternalByBook = {}
CPetLearnInternalByBook.__index = CPetLearnInternalByBook



CPetLearnInternalByBook.PROTOCOL_TYPE = 788480

function CPetLearnInternalByBook.Create()
	print("enter CPetLearnInternalByBook create")
	return CPetLearnInternalByBook:new()
end
function CPetLearnInternalByBook:new()
	local self = {}
	setmetatable(self, CPetLearnInternalByBook)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.bookkey = 0
	self.idx=0
	return self
end
function CPetLearnInternalByBook:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetLearnInternalByBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.bookkey)
	_os_:marshal_int32(self.idx)
	return _os_
end

function CPetLearnInternalByBook:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.bookkey = _os_:unmarshal_int32()
	self.idx = _os_:unmarshal_int32()
	return _os_
end

return CPetLearnInternalByBook
