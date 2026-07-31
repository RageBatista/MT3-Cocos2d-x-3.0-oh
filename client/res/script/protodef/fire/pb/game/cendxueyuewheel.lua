require "utils.tableutil"
CEndXueYueWheel = {}
CEndXueYueWheel.__index = CEndXueYueWheel



CEndXueYueWheel.PROTOCOL_TYPE = 810368

function CEndXueYueWheel.Create()
	print("enter CEndXueYueWheel create")
	return CEndXueYueWheel:new()
end
function CEndXueYueWheel:new()
	local self = {}
	setmetatable(self, CEndXueYueWheel)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CEndXueYueWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEndXueYueWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CEndXueYueWheel:unmarshal(_os_)
	return _os_
end

return CEndXueYueWheel
