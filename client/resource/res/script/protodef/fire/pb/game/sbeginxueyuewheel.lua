require "utils.tableutil"
SBeginXueYueWheel = {}
SBeginXueYueWheel.__index = SBeginXueYueWheel



SBeginXueYueWheel.PROTOCOL_TYPE = 810367

function SBeginXueYueWheel.Create()
	print("enter SBeginXueYueWheel create")
	return SBeginXueYueWheel:new()
end
function SBeginXueYueWheel:new()
	local self = {}
	setmetatable(self, SBeginXueYueWheel)
	self.type = self.PROTOCOL_TYPE
	self.wheelindex = 0

	return self
end
function SBeginXueYueWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBeginXueYueWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.wheelindex)
	return _os_
end

function SBeginXueYueWheel:unmarshal(_os_)
	self.wheelindex = _os_:unmarshal_int32()
	return _os_
end

return SBeginXueYueWheel
