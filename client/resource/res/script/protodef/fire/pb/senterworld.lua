require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.formbean"
require "protodef.rpcgen.fire.pb.item"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
require "protodef.rpcgen.fire.pb.rolebasicfightproperties"
require "protodef.rpcgen.fire.pb.roledetail"
require "protodef.rpcgen.fire.pb.title.titleinfo"
SEnterWorld = {}
SEnterWorld.__index = SEnterWorld



SEnterWorld.PROTOCOL_TYPE = 786438

function SEnterWorld.Create()
	print("enter SEnterWorld create")
	return SEnterWorld:new()
end
function SEnterWorld:new()
	local self = {}
	setmetatable(self, SEnterWorld)
	self.type = self.PROTOCOL_TYPE
	self.mydata = RoleDetail:new()

	return self
end
function SEnterWorld:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SEnterWorld:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.mydata:marshal(_os_) 
	return _os_
end

function SEnterWorld:unmarshal(_os_)
	----------------unmarshal bean

	self.mydata:unmarshal(_os_)

	return _os_
end

return SEnterWorld
