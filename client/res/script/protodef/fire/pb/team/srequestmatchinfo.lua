require "utils.tableutil"
SRequestMatchInfo = {}
SRequestMatchInfo.__index = SRequestMatchInfo



SRequestMatchInfo.PROTOCOL_TYPE = 794513

function SRequestMatchInfo.Create()
	print("enter SRequestMatchInfo create")
	return SRequestMatchInfo:new()
end
function SRequestMatchInfo:new()
	local self = {}
	setmetatable(self, SRequestMatchInfo)
	self.type = self.PROTOCOL_TYPE
	self.teammatchnum = 0
	self.playermatchnum = 0

	return self
end
function SRequestMatchInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestMatchInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.teammatchnum)
	_os_:marshal_int32(self.playermatchnum)
	return _os_
end

function SRequestMatchInfo:unmarshal(_os_)
	self.teammatchnum = _os_:unmarshal_int32()
	self.playermatchnum = _os_:unmarshal_int32()
	return _os_
end

return SRequestMatchInfo
