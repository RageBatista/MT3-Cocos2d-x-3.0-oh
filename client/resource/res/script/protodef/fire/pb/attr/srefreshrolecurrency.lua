require "utils.tableutil"
SRefreshRoleCurrency = {}
SRefreshRoleCurrency.__index = SRefreshRoleCurrency



SRefreshRoleCurrency.PROTOCOL_TYPE = 799437

function SRefreshRoleCurrency.Create()
	print("enter SRefreshRoleCurrency create")
	return SRefreshRoleCurrency:new()
end
function SRefreshRoleCurrency:new()
	local self = {}
	setmetatable(self, SRefreshRoleCurrency)
	self.type = self.PROTOCOL_TYPE
	self.datas = {}

	return self
end
function SRefreshRoleCurrency:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshRoleCurrency:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in pairs(self.datas) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRefreshRoleCurrency:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.datas[newkey] = newvalue
	end
	return _os_
end

return SRefreshRoleCurrency
