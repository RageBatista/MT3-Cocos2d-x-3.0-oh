require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.item"
SGetDepotInfo = {}
SGetDepotInfo.__index = SGetDepotInfo



SGetDepotInfo.PROTOCOL_TYPE = 787770

function SGetDepotInfo.Create()
	print("enter SGetDepotInfo create")
	return SGetDepotInfo:new()
end
function SGetDepotInfo:new()
	local self = {}
	setmetatable(self, SGetDepotInfo)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0
	self.baginfo = Bag:new()

	return self
end
function SGetDepotInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetDepotInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	----------------marshal bean
	self.baginfo:marshal(_os_) 
	return _os_
end

function SGetDepotInfo:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.baginfo:unmarshal(_os_)

	return _os_
end

return SGetDepotInfo
