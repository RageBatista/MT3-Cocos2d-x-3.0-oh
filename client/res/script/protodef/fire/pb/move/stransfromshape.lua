require "utils.tableutil"
STransfromShape = {}
STransfromShape.__index = STransfromShape



STransfromShape.PROTOCOL_TYPE = 790465

function STransfromShape.Create()
	print("enter STransfromShape create")
	return STransfromShape:new()
end
function STransfromShape:new()
	local self = {}
	setmetatable(self, STransfromShape)
	self.type = self.PROTOCOL_TYPE
	self.playerid = 0
	self.shape = 0

	return self
end
function STransfromShape:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STransfromShape:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.playerid)
	_os_:marshal_int32(self.shape)
	return _os_
end

function STransfromShape:unmarshal(_os_)
	self.playerid = _os_:unmarshal_int64()
	self.shape = _os_:unmarshal_int32()
	return _os_
end

return STransfromShape
