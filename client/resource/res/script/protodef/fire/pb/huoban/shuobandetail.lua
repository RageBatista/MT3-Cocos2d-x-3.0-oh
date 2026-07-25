require "utils.tableutil"
require "protodef.rpcgen.fire.pb.huoban.huobandetailinfo"
SHuobanDetail = {}
SHuobanDetail.__index = SHuobanDetail



SHuobanDetail.PROTOCOL_TYPE = 818835

function SHuobanDetail.Create()
	print("enter SHuobanDetail create")
	return SHuobanDetail:new()
end
function SHuobanDetail:new()
	local self = {}
	setmetatable(self, SHuobanDetail)
	self.type = self.PROTOCOL_TYPE
	self.huoban = HuoBanDetailInfo:new()

	return self
end
function SHuobanDetail:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SHuobanDetail:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.huoban:marshal(_os_) 
	return _os_
end

function SHuobanDetail:unmarshal(_os_)
	----------------unmarshal bean

	self.huoban:unmarshal(_os_)

	return _os_
end

return SHuobanDetail
