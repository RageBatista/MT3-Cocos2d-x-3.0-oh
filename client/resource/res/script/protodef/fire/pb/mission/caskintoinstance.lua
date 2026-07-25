require "utils.tableutil"
CAskIntoInstance = {}
CAskIntoInstance.__index = CAskIntoInstance



CAskIntoInstance.PROTOCOL_TYPE = 805539

function CAskIntoInstance.Create()
	print("enter CAskIntoInstance create")
	return CAskIntoInstance:new()
end
function CAskIntoInstance:new()
	local self = {}
	setmetatable(self, CAskIntoInstance)
	self.type = self.PROTOCOL_TYPE
	self.answer = 0
	self.insttype = 0

	return self
end
function CAskIntoInstance:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAskIntoInstance:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.answer)
	_os_:marshal_int32(self.insttype)
	return _os_
end

function CAskIntoInstance:unmarshal(_os_)
	self.answer = _os_:unmarshal_short()
	self.insttype = _os_:unmarshal_int32()
	return _os_
end

return CAskIntoInstance
