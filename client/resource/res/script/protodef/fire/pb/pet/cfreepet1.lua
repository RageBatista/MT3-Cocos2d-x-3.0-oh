require "utils.tableutil"
CFreePet1 = {}
CFreePet1.__index = CFreePet1



CFreePet1.PROTOCOL_TYPE = 788497

function CFreePet1.Create()
	print("enter CFreePet1 create")
	return CFreePet1:new()
end
function CFreePet1:new()
	local self = {}
	setmetatable(self, CFreePet1)
	self.type = self.PROTOCOL_TYPE
	self.petkeys = {}

	return self
end
function CFreePet1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFreePet1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.petkeys))
	for k,v in ipairs(self.petkeys) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function CFreePet1:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_petkeys=0,_os_null_petkeys
	_os_null_petkeys, sizeof_petkeys = _os_: uncompact_uint32(sizeof_petkeys)
	for k = 1,sizeof_petkeys do
		self.petkeys[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return CFreePet1
