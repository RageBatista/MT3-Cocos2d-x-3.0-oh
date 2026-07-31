require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SMarketPetTips = {}
SMarketPetTips.__index = SMarketPetTips



SMarketPetTips.PROTOCOL_TYPE = 810650

function SMarketPetTips.Create()
	print("enter SMarketPetTips create")
	return SMarketPetTips:new()
end
function SMarketPetTips:new()
	local self = {}
	setmetatable(self, SMarketPetTips)
	self.type = self.PROTOCOL_TYPE
	self.pettips = Pet:new()
	self.tipstype = 0

	return self
end
function SMarketPetTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketPetTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.pettips:marshal(_os_) 
	_os_:marshal_int32(self.tipstype)
	return _os_
end

function SMarketPetTips:unmarshal(_os_)
	----------------unmarshal bean

	self.pettips:unmarshal(_os_)

	self.tipstype = _os_:unmarshal_int32()
	return _os_
end

return SMarketPetTips
