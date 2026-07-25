require "utils.tableutil"
CRuneGive = {}
CRuneGive.__index = CRuneGive



CRuneGive.PROTOCOL_TYPE = 808509

function CRuneGive.Create()
	print("enter CRuneGive create")
	return CRuneGive:new()
end
function CRuneGive:new()
	local self = {}
	setmetatable(self, CRuneGive)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.givetype = 0
	self.givevalue = 0
	self.itemkey = 0
	self.bagtype = 0

	return self
end
function CRuneGive:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRuneGive:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.givetype)
	_os_:marshal_int32(self.givevalue)
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int32(self.bagtype)
	return _os_
end

function CRuneGive:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.givetype = _os_:unmarshal_int32()
	self.givevalue = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	self.bagtype = _os_:unmarshal_int32()
	return _os_
end

return CRuneGive
