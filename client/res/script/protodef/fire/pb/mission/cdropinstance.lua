require "utils.tableutil"
CDropInstance = {}
CDropInstance.__index = CDropInstance



CDropInstance.PROTOCOL_TYPE = 805550

function CDropInstance.Create()
	print("enter CDropInstance create")
	return CDropInstance:new()
end
function CDropInstance:new()
	local self = {}
	setmetatable(self, CDropInstance)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CDropInstance:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDropInstance:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CDropInstance:unmarshal(_os_)
	return _os_
end

return CDropInstance
