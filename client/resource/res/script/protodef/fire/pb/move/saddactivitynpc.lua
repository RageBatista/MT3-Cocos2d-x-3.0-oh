require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SAddActivityNpc = {}
SAddActivityNpc.__index = SAddActivityNpc



SAddActivityNpc.PROTOCOL_TYPE = 790463

function SAddActivityNpc.Create()
	print("enter SAddActivityNpc create")
	return SAddActivityNpc:new()
end
function SAddActivityNpc:new()
	local self = {}
	setmetatable(self, SAddActivityNpc)
	self.type = self.PROTOCOL_TYPE
	self.npcids = {}
	self.poslist = {}

	return self
end
function SAddActivityNpc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddActivityNpc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.npcids))
	for k,v in ipairs(self.npcids) do
		_os_:marshal_int32(v)
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.poslist))
	for k,v in ipairs(self.poslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SAddActivityNpc:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_npcids=0,_os_null_npcids
	_os_null_npcids, sizeof_npcids = _os_: uncompact_uint32(sizeof_npcids)
	for k = 1,sizeof_npcids do
		self.npcids[k] = _os_:unmarshal_int32()
	end
	----------------unmarshal vector
	local sizeof_poslist=0,_os_null_poslist
	_os_null_poslist, sizeof_poslist = _os_: uncompact_uint32(sizeof_poslist)
	for k = 1,sizeof_poslist do
		----------------unmarshal bean
		self.poslist[k]=Pos:new()

		self.poslist[k]:unmarshal(_os_)

	end
	return _os_
end

return SAddActivityNpc
