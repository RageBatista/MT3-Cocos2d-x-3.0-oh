require "utils.tableutil"
CPetLevelReset = {}
CPetLevelReset.__index = CPetLevelReset



CPetLevelReset.PROTOCOL_TYPE = 788543

function CPetLevelReset.Create()
	print("enter CPetLevelReset create")
	return CPetLevelReset:new()
end
function CPetLevelReset:new()
	local self = {}
	setmetatable(self, CPetLevelReset)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.itemkey = 0

	return self
end
function CPetLevelReset:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetLevelReset:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CPetLevelReset:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CPetLevelReset
