require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SSendRankPetData = {}
SSendRankPetData.__index = SSendRankPetData



SSendRankPetData.PROTOCOL_TYPE = 810241

function SSendRankPetData.Create()
	print("enter SSendRankPetData create")
	return SSendRankPetData:new()
end
function SSendRankPetData:new()
	local self = {}
	setmetatable(self, SSendRankPetData)
	self.type = self.PROTOCOL_TYPE
	self.uniquepetid = 0
	self.petinfo = Pet:new()

	return self
end
function SSendRankPetData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRankPetData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniquepetid)
	----------------marshal bean
	self.petinfo:marshal(_os_) 
	return _os_
end

function SSendRankPetData:unmarshal(_os_)
	self.uniquepetid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.petinfo:unmarshal(_os_)

	return _os_
end

return SSendRankPetData
