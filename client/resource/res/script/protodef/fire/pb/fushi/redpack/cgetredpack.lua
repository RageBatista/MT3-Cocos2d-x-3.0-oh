require "utils.tableutil"
CGetRedPack = {}
CGetRedPack.__index = CGetRedPack



CGetRedPack.PROTOCOL_TYPE = 812536

function CGetRedPack.Create()
	print("enter CGetRedPack create")
	return CGetRedPack:new()
end
function CGetRedPack:new()
	local self = {}
	setmetatable(self, CGetRedPack)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.redpackid = "" 

	return self
end
function CGetRedPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRedPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	return _os_
end

function CGetRedPack:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	return _os_
end

return CGetRedPack
