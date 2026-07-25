require "utils.tableutil"
require "protodef.rpcgen.fire.pb.huoban.zhenronginfo"
SZhenrongInfo = {}
SZhenrongInfo.__index = SZhenrongInfo



SZhenrongInfo.PROTOCOL_TYPE = 818836

function SZhenrongInfo.Create()
	print("enter SZhenrongInfo create")
	return SZhenrongInfo:new()
end
function SZhenrongInfo:new()
	local self = {}
	setmetatable(self, SZhenrongInfo)
	self.type = self.PROTOCOL_TYPE
	self.dangqianzhenrong = 0
	self.zhenrongxinxi = {}

	return self
end
function SZhenrongInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SZhenrongInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.dangqianzhenrong)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.zhenrongxinxi))
	for k,v in pairs(self.zhenrongxinxi) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SZhenrongInfo:unmarshal(_os_)
	self.dangqianzhenrong = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_zhenrongxinxi=0,_os_null_zhenrongxinxi
	_os_null_zhenrongxinxi, sizeof_zhenrongxinxi = _os_: uncompact_uint32(sizeof_zhenrongxinxi)
	for k = 1,sizeof_zhenrongxinxi do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=ZhenrongInfo:new()

		newvalue:unmarshal(_os_)

		self.zhenrongxinxi[newkey] = newvalue
	end
	return _os_
end

return SZhenrongInfo
