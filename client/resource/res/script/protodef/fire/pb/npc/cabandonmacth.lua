require "utils.tableutil"
CAbandonMacth = {}
CAbandonMacth.__index = CAbandonMacth



CAbandonMacth.PROTOCOL_TYPE = 795670

function CAbandonMacth.Create()
	print("enter CAbandonMacth create")
	return CAbandonMacth:new()
end
function CAbandonMacth:new()
	local self = {}
	setmetatable(self, CAbandonMacth)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0

	return self
end
function CAbandonMacth:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAbandonMacth:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CAbandonMacth:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CAbandonMacth
