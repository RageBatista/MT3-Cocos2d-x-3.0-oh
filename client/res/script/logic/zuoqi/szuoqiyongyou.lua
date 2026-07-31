require "utils.tableutil"
SZuoQiYongYou = {}
SZuoQiYongYou.__index = SZuoQiYongYou



SZuoQiYongYou.PROTOCOL_TYPE = 800022

function SZuoQiYongYou.Create()
	print("enter CChangeSchool create")
	return SZuoQiYongYou:new()
end
function SZuoQiYongYou:new()
	local self = {}
	setmetatable(self, SZuoQiYongYou)
	self.type = self.PROTOCOL_TYPE
	self.zuoqix = {}
	return self
end
function SZuoQiYongYou:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SZuoQiYongYou:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:compact_uint32(TableUtil.tablelength(self.zuoqix))
	for k,v in pairs(self.zuoqix) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	return _os_
end

function SZuoQiYongYou:unmarshal(_os_)
	local sizeof_zuoqi=0,_os_null_zuoqi
	_os_null_zuoqi, sizeof_zuoqi = _os_: uncompact_uint32(sizeof_zuoqi)
	for k = 1,sizeof_zuoqi do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.zuoqix[newkey] = newvalue
	end
	return _os_
end

return SZuoQiYongYou
