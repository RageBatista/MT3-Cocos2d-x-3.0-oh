require "utils.tableutil"
SHeChengRet = {}
SHeChengRet.__index = SHeChengRet



SHeChengRet.PROTOCOL_TYPE = 787488

function SHeChengRet.Create()
	print("enter SHeChengRet create")
	return SHeChengRet:new()
end
function SHeChengRet:new()
	local self = {}
	setmetatable(self, SHeChengRet)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0

	return self
end
function SHeChengRet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SHeChengRet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	return _os_
end

function SHeChengRet:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SHeChengRet
