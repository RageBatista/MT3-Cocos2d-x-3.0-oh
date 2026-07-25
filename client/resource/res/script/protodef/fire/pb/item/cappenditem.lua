require "utils.tableutil"
CAppendItem = {}
CAppendItem.__index = CAppendItem



CAppendItem.PROTOCOL_TYPE = 787455

function CAppendItem.Create()
	print("enter CAppendItem create")
	return CAppendItem:new()
end
function CAppendItem:new()
	local self = {}
	setmetatable(self, CAppendItem)
	self.type = self.PROTOCOL_TYPE
	self.keyinpack = 0
	self.idtype = 0
	self.id = 0
	self.isalluse=0

	return self
end
function CAppendItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAppendItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.idtype)
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.isalluse)
	return _os_
end

function CAppendItem:unmarshal(_os_)
	self.keyinpack = _os_:unmarshal_int32()
	self.idtype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int64()
	self.isalluse = _os_:unmarshal_int32()
	return _os_
end

return CAppendItem
