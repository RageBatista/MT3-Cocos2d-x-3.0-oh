require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.item"
SGetPackInfo = {}
SGetPackInfo.__index = SGetPackInfo



SGetPackInfo.PROTOCOL_TYPE = 787443

function SGetPackInfo.Create()
	print("enter SGetPackInfo create")
	return SGetPackInfo:new()
end
function SGetPackInfo:new()
	local self = {}
	setmetatable(self, SGetPackInfo)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.baginfo = Bag:new()

	return self
end
function SGetPackInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetPackInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	----------------marshal bean
	self.baginfo:marshal(_os_) 
	return _os_
end

function SGetPackInfo:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.baginfo:unmarshal(_os_)

	return _os_
end

return SGetPackInfo
