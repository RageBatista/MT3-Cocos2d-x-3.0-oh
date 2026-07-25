require "utils.tableutil"
CAskLandTimes = {}
CAskLandTimes.__index = CAskLandTimes



CAskLandTimes.PROTOCOL_TYPE = 805469

function CAskLandTimes.Create()
	print("enter CAskLandTimes create")
	return CAskLandTimes:new()
end
function CAskLandTimes:new()
	local self = {}
	setmetatable(self, CAskLandTimes)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CAskLandTimes:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAskLandTimes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CAskLandTimes:unmarshal(_os_)
	return _os_
end

return CAskLandTimes
