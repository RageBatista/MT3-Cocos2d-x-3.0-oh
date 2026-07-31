require "utils.tableutil"
CPetLearnSkillByBook = {}
CPetLearnSkillByBook.__index = CPetLearnSkillByBook



CPetLearnSkillByBook.PROTOCOL_TYPE = 788479

function CPetLearnSkillByBook.Create()
	print("enter CPetLearnSkillByBook create")
	return CPetLearnSkillByBook:new()
end
function CPetLearnSkillByBook:new()
	local self = {}
	setmetatable(self, CPetLearnSkillByBook)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.bookkey = 0

	return self
end
function CPetLearnSkillByBook:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetLearnSkillByBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.bookkey)
	return _os_
end

function CPetLearnSkillByBook:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.bookkey = _os_:unmarshal_int32()
	return _os_
end

return CPetLearnSkillByBook
