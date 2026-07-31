require "utils.tableutil"
SItemNumChange = {}
SItemNumChange.__index = SItemNumChange



SItemNumChange.PROTOCOL_TYPE = 787434

function SItemNumChange.Create()
	print("enter SItemNumChange create")
	return SItemNumChange:new()
end
function SItemNumChange:new()
	local self = {}
	setmetatable(self, SItemNumChange)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.curnum = 0

	return self
end
function SItemNumChange:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemNumChange:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.curnum)
	return _os_
end

function SItemNumChange:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.curnum = _os_:unmarshal_int32()
	return _os_
end

return SItemNumChange
