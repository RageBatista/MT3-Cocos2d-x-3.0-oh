require "utils.tableutil"
CGrabBonus = {}
CGrabBonus.__index = CGrabBonus



CGrabBonus.PROTOCOL_TYPE = 808474

function CGrabBonus.Create()
	print("enter CGrabBonus create")
	return CGrabBonus:new()
end
function CGrabBonus:new()
	local self = {}
	setmetatable(self, CGrabBonus)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGrabBonus:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGrabBonus:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGrabBonus:unmarshal(_os_)
	return _os_
end

return CGrabBonus
