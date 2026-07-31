require "utils.tableutil"
SRemoveActivityNpc = {}
SRemoveActivityNpc.__index = SRemoveActivityNpc



SRemoveActivityNpc.PROTOCOL_TYPE = 790464

function SRemoveActivityNpc.Create()
	print("enter SRemoveActivityNpc create")
	return SRemoveActivityNpc:new()
end
function SRemoveActivityNpc:new()
	local self = {}
	setmetatable(self, SRemoveActivityNpc)
	self.type = self.PROTOCOL_TYPE
	self.npcids = {}

	return self
end
function SRemoveActivityNpc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemoveActivityNpc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.npcids))
	for k,v in ipairs(self.npcids) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SRemoveActivityNpc:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_npcids=0,_os_null_npcids
	_os_null_npcids, sizeof_npcids = _os_: uncompact_uint32(sizeof_npcids)
	for k = 1,sizeof_npcids do
		self.npcids[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SRemoveActivityNpc
