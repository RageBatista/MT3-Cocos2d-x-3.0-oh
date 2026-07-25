require "utils.tableutil"
SUpdateInborn = {}
SUpdateInborn.__index = SUpdateInborn



SUpdateInborn.PROTOCOL_TYPE = 800446

function SUpdateInborn.Create()
	print("enter SUpdateInborn create")
	return SUpdateInborn:new()
end
function SUpdateInborn:new()
	local self = {}
	setmetatable(self, SUpdateInborn)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0
	self.inborns = {}

	return self
end
function SUpdateInborn:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateInborn:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.flag)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.inborns))
	for k,v in pairs(self.inborns) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SUpdateInborn:unmarshal(_os_)
	self.flag = _os_:unmarshal_char()
	----------------unmarshal map
	local sizeof_inborns=0,_os_null_inborns
	_os_null_inborns, sizeof_inborns = _os_: uncompact_uint32(sizeof_inborns)
	for k = 1,sizeof_inborns do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.inborns[newkey] = newvalue
	end
	return _os_
end

return SUpdateInborn
