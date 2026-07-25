require "utils.tableutil"
CQueryPotentialFruit = {}
CQueryPotentialFruit.__index = CQueryPotentialFruit



CQueryPotentialFruit.PROTOCOL_TYPE = 810501

function CQueryPotentialFruit.Create()
	print("enter CQueryPotentialFruit create")
	return CQueryPotentialFruit:new()
end
function CQueryPotentialFruit:new()
	local self = {}
	setmetatable(self, CQueryPotentialFruit)
	self.type = self.PROTOCOL_TYPE

	return self
end
function CQueryPotentialFruit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryPotentialFruit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	return _os_
end

function CQueryPotentialFruit:unmarshal(_os_)
	return _os_
end

return CQueryPotentialFruit
