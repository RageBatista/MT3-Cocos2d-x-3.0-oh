require "utils.tableutil"
CPetYiWangSkillByBook = {}
CPetYiWangSkillByBook.__index = CPetYiWangSkillByBook



CPetYiWangSkillByBook.PROTOCOL_TYPE = 789000

function CPetYiWangSkillByBook.Create()
	print("enter CPetYiWangSkillByBook create")
	return CPetYiWangSkillByBook:new()
end
function CPetYiWangSkillByBook:new()
	local self = {}
	setmetatable(self, CPetYiWangSkillByBook)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.skillid = 0

	return self
end
function CPetYiWangSkillByBook:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetYiWangSkillByBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.skillid)
	return _os_
end

function CPetYiWangSkillByBook:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.skillid = _os_:unmarshal_int32()
	return _os_
end

return CPetYiWangSkillByBook
