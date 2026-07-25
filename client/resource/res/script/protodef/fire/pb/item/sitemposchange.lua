require "utils.tableutil"
SItemPosChange = {}
SItemPosChange.__index = SItemPosChange



SItemPosChange.PROTOCOL_TYPE = 787441

function SItemPosChange.Create()
	print("enter SItemPosChange create")
	return SItemPosChange:new()
end
function SItemPosChange:new()
	local self = {}
	setmetatable(self, SItemPosChange)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.pos = 0

	return self
end
function SItemPosChange:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemPosChange:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.pos)
	return _os_
end

function SItemPosChange:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.pos = _os_:unmarshal_int32()
	return _os_
end

return SItemPosChange
