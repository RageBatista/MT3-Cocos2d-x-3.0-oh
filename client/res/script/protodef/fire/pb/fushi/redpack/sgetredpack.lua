require "utils.tableutil"
SGetRedPack = {}
SGetRedPack.__index = SGetRedPack



SGetRedPack.PROTOCOL_TYPE = 812537

function SGetRedPack.Create()
	print("enter SGetRedPack create")
	return SGetRedPack:new()
end
function SGetRedPack:new()
	local self = {}
	setmetatable(self, SGetRedPack)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.redpackid = "" 
	self.state = 0
	self.successflag = 0
	self.fushinum = 0

	return self
end
function SGetRedPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetRedPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.successflag)
	_os_:marshal_int32(self.fushinum)
	return _os_
end

function SGetRedPack:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	self.state = _os_:unmarshal_int32()
	self.successflag = _os_:unmarshal_int32()
	self.fushinum = _os_:unmarshal_int32()
	return _os_
end

return SGetRedPack
