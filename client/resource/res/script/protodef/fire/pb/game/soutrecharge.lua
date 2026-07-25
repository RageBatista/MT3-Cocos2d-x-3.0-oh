require "utils.tableutil"
SOutRecharge = {}
SOutRecharge.__index = SOutRecharge



SOutRecharge.PROTOCOL_TYPE = 817968

function SOutRecharge.Create()
	print("enter SOutRecharge create")
	return SOutRecharge:new()
end
function SOutRecharge:new()
	local self = {}
	setmetatable(self, SOutRecharge)
	self.type = self.PROTOCOL_TYPE
	self.pay = 0
	self.total = 0
	self.dayrewardmap = {}
	self.totalrewardmap = {}

	return self
end
function SOutRecharge:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOutRecharge:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pay)
    _os_:compact_uint32(TableUtil.tablelength(self.dayrewardmap))
	for k,v in pairs(self.dayrewardmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end
	----------------marshal map
	_os_:marshal_int64(self.total)
	_os_:compact_uint32(TableUtil.tablelength(self.totalrewardmap))
	for k,v in pairs(self.totalrewardmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SOutRecharge:unmarshal(_os_)
	self.pay = _os_:unmarshal_int64()
	local sizeof_dayrewardmap=0,_os_null_dayrewardmap
	_os_null_dayrewardmap, sizeof_dayrewardmap = _os_: uncompact_uint32(sizeof_dayrewardmap)
	for k = 1,sizeof_dayrewardmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.dayrewardmap[newkey] = newvalue
	end
	self.total = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_totalrewardmap=0,_os_null_totalrewardmap
	_os_null_totalrewardmap, sizeof_totalrewardmap = _os_: uncompact_uint32(sizeof_totalrewardmap)
	for k = 1,sizeof_totalrewardmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.totalrewardmap[newkey] = newvalue
	end
	return _os_
end

return SOutRecharge
