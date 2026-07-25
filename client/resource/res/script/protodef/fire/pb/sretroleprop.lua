require "utils.tableutil"
SRetRoleProp = {}
SRetRoleProp.__index = SRetRoleProp



SRetRoleProp.PROTOCOL_TYPE = 786454

function SRetRoleProp.Create()
	print("enter SRetRoleProp create")
	return SRetRoleProp:new()
end
function SRetRoleProp:new()
	local self = {}
	setmetatable(self, SRetRoleProp)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.datas = {}

	return self
end
function SRetRoleProp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRetRoleProp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in pairs(self.datas) do
		_os_:marshal_int32(k)
		_os_:marshal_float(v)
	end

	return _os_
end

function SRetRoleProp:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_float()
		self.datas[newkey] = newvalue
	end
	return _os_
end

return SRetRoleProp
