require "utils.tableutil"
SChangeZhenrong = {}
SChangeZhenrong.__index = SChangeZhenrong



SChangeZhenrong.PROTOCOL_TYPE = 818839

function SChangeZhenrong.Create()
	print("enter SChangeZhenrong create")
	return SChangeZhenrong:new()
end
function SChangeZhenrong:new()
	local self = {}
	setmetatable(self, SChangeZhenrong)
	self.type = self.PROTOCOL_TYPE
	self.zhenrong = 0
	self.zhenfa = 0
	self.huobanlist = {}
	self.reason = 0

	return self
end
function SChangeZhenrong:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeZhenrong:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zhenrong)
	_os_:marshal_int32(self.zhenfa)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.huobanlist))
	for k,v in ipairs(self.huobanlist) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.reason)
	return _os_
end

function SChangeZhenrong:unmarshal(_os_)
	self.zhenrong = _os_:unmarshal_int32()
	self.zhenfa = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_huobanlist=0,_os_null_huobanlist
	_os_null_huobanlist, sizeof_huobanlist = _os_: uncompact_uint32(sizeof_huobanlist)
	for k = 1,sizeof_huobanlist do
		self.huobanlist[k] = _os_:unmarshal_int32()
	end
	self.reason = _os_:unmarshal_int32()
	return _os_
end

return SChangeZhenrong
