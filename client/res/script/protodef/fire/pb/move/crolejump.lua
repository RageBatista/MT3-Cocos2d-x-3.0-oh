require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
CRoleJump = {}
CRoleJump.__index = CRoleJump



CRoleJump.PROTOCOL_TYPE = 790477

function CRoleJump.Create()
	print("enter CRoleJump create")
	return CRoleJump:new()
end
function CRoleJump:new()
	local self = {}
	setmetatable(self, CRoleJump)
	self.type = self.PROTOCOL_TYPE
	self.poslist = {}
	self.srcpos = Pos:new()
	self.destpos = Pos:new()
	self.jumptype = 0
	self.sceneid = 0

	return self
end
function CRoleJump:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRoleJump:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.poslist))
	for k,v in ipairs(self.poslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	----------------marshal bean
	self.srcpos:marshal(_os_) 
	----------------marshal bean
	self.destpos:marshal(_os_) 
	_os_:marshal_char(self.jumptype)
	_os_:marshal_int64(self.sceneid)
	return _os_
end

function CRoleJump:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_poslist=0 ,_os_null_poslist
	_os_null_poslist, sizeof_poslist = _os_: uncompact_uint32(sizeof_poslist)
	for k = 1,sizeof_poslist do
		----------------unmarshal bean
		self.poslist[k]=Pos:new()

		self.poslist[k]:unmarshal(_os_)

	end
	----------------unmarshal bean

	self.srcpos:unmarshal(_os_)

	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	self.jumptype = _os_:unmarshal_char()
	self.sceneid = _os_:unmarshal_int64()
	return _os_
end

return CRoleJump
