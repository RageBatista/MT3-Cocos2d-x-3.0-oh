require "utils.tableutil"
SYiChuYongYou = {}
SYiChuYongYou.__index = SYiChuYongYou



SYiChuYongYou.PROTOCOL_TYPE = 800013

function SYiChuYongYou.Create()
	print("enter CChangeSchool create")
	return SYiChuYongYou:new()
end
function SYiChuYongYou:new()
	local self = {}
	setmetatable(self, SYiChuYongYou)
	self.type = self.PROTOCOL_TYPE
	self.shizhuang = {}
	return self
end
function SYiChuYongYou:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SYiChuYongYou:marshal(ostream)

	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:compact_uint32(TableUtil.tablelength(self.shizhuang))
	for k,v in pairs(self.shizhuang) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	return _os_
end

function SYiChuYongYou:unmarshal(_os_)

	local sizeof_shizhuang=0,_os_null_shizhuang
	_os_null_shizhuang, sizeof_shizhuang = _os_: uncompact_uint32(sizeof_shizhuang)
	for k = 1,sizeof_shizhuang do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.shizhuang[newkey] = newvalue
	end
	return _os_
end

return SYiChuYongYou
