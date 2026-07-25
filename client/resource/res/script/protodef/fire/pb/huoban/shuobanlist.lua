require "utils.tableutil"
require "protodef.rpcgen.fire.pb.huoban.huobaninfo"
SHuobanList = {}
SHuobanList.__index = SHuobanList



SHuobanList.PROTOCOL_TYPE = 818833

function SHuobanList.Create()
	print("enter SHuobanList create")
	return SHuobanList:new()
end
function SHuobanList:new()
	local self = {}
	setmetatable(self, SHuobanList)
	self.type = self.PROTOCOL_TYPE
	self.huobans = {}

	return self
end
function SHuobanList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SHuobanList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.huobans))
	for k,v in ipairs(self.huobans) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SHuobanList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_huobans=0,_os_null_huobans
	_os_null_huobans, sizeof_huobans = _os_: uncompact_uint32(sizeof_huobans)
	for k = 1,sizeof_huobans do
		----------------unmarshal bean
		self.huobans[k]=HuoBanInfo:new()

		self.huobans[k]:unmarshal(_os_)

	end
	return _os_
end

return SHuobanList
