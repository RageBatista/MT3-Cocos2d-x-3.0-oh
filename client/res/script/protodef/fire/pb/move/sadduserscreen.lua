require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.npcbasic"
require "protodef.rpcgen.fire.pb.move.pos"
require "protodef.rpcgen.fire.pb.move.rolebasic"
SAddUserScreen = {}
SAddUserScreen.__index = SAddUserScreen



SAddUserScreen.PROTOCOL_TYPE = 790437

function SAddUserScreen.Create()
	print("enter SAddUserScreen create")
	return SAddUserScreen:new()
end
function SAddUserScreen:new()
	local self = {}
	setmetatable(self, SAddUserScreen)
	self.type = self.PROTOCOL_TYPE
	self.rolelist = {}
	self.npclist = {}

	return self
end
function SAddUserScreen:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddUserScreen:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolelist))
	for k,v in ipairs(self.rolelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.npclist))
	for k,v in ipairs(self.npclist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SAddUserScreen:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_rolelist=0 ,_os_null_rolelist
	_os_null_rolelist, sizeof_rolelist = _os_: uncompact_uint32(sizeof_rolelist)
	for k = 1,sizeof_rolelist do
		----------------unmarshal bean
		self.rolelist[k]=RoleBasic:new()

		self.rolelist[k]:unmarshal(_os_)

	end
	----------------unmarshal list
	local sizeof_npclist=0 ,_os_null_npclist
	_os_null_npclist, sizeof_npclist = _os_: uncompact_uint32(sizeof_npclist)
	for k = 1,sizeof_npclist do
		----------------unmarshal bean
		self.npclist[k]=NpcBasic:new()

		self.npclist[k]:unmarshal(_os_)

	end
	return _os_
end

return SAddUserScreen
