require "utils.tableutil"
CSendRedPack = {}
CSendRedPack.__index = CSendRedPack



CSendRedPack.PROTOCOL_TYPE = 812534

function CSendRedPack.Create()
	print("enter CSendRedPack create")
	return CSendRedPack:new()
end
function CSendRedPack:new()
	local self = {}
	setmetatable(self, CSendRedPack)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.fushinum = 0
	self.redpacknum = 0
	self.redpackdes = "" 

	return self
end
function CSendRedPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendRedPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_int32(self.fushinum)
	_os_:marshal_int32(self.redpacknum)
	_os_:marshal_wstring(self.redpackdes)
	return _os_
end

function CSendRedPack:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.fushinum = _os_:unmarshal_int32()
	self.redpacknum = _os_:unmarshal_int32()
	self.redpackdes = _os_:unmarshal_wstring(self.redpackdes)
	return _os_
end

return CSendRedPack
