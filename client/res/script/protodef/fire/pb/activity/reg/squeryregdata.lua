require "utils.tableutil"
SQueryRegData = {}
SQueryRegData.__index = SQueryRegData



SQueryRegData.PROTOCOL_TYPE = 810533

function SQueryRegData.Create()
	print("enter SQueryRegData create")
	return SQueryRegData:new()
end
function SQueryRegData:new()
	local self = {}
	setmetatable(self, SQueryRegData)
	self.type = self.PROTOCOL_TYPE
	self.month = 0
	self.times = 0
	self.suppregtimes = 0
	self.cansuppregtimes = 0
	self.suppregdays = {}
	self.rewardflag = 0

	return self
end
function SQueryRegData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQueryRegData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.month)
	_os_:marshal_int32(self.times)
	_os_:marshal_int32(self.suppregtimes)
	_os_:marshal_int32(self.cansuppregtimes)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.suppregdays))
	for k,v in ipairs(self.suppregdays) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.rewardflag)
	return _os_
end

function SQueryRegData:unmarshal(_os_)
	self.month = _os_:unmarshal_int32()
	self.times = _os_:unmarshal_int32()
	self.suppregtimes = _os_:unmarshal_int32()
	self.cansuppregtimes = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_suppregdays=0,_os_null_suppregdays
	_os_null_suppregdays, sizeof_suppregdays = _os_: uncompact_uint32(sizeof_suppregdays)
	for k = 1,sizeof_suppregdays do
		self.suppregdays[k] = _os_:unmarshal_int32()
	end
	self.rewardflag = _os_:unmarshal_int32()
	return _os_
end

return SQueryRegData
