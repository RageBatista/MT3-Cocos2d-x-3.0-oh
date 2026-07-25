require "utils.tableutil"
SCancelTrading = {}
SCancelTrading.__index = SCancelTrading



SCancelTrading.PROTOCOL_TYPE = 812644

function SCancelTrading.Create()
	print("enter SCancelTrading create")
	return SCancelTrading:new()
end
function SCancelTrading:new()
	local self = {}
	setmetatable(self, SCancelTrading)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SCancelTrading:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCancelTrading:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SCancelTrading:unmarshal(_os_)
	return _os_
end

return SCancelTrading
