require "utils.tableutil"
SSubmit2Npc = {}
SSubmit2Npc.__index = SSubmit2Npc



SSubmit2Npc.PROTOCOL_TYPE = 795455

function SSubmit2Npc.Create()
	print("enter SSubmit2Npc create")
	return SSubmit2Npc:new()
end
function SSubmit2Npc:new()
	local self = {}
	setmetatable(self, SSubmit2Npc)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.npckey = 0
	self.submittype = 0
	self.availableids = {}
	self.availablepos = 0

	return self
end
function SSubmit2Npc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSubmit2Npc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.submittype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.availableids))
	for k,v in ipairs(self.availableids) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.availablepos)
	return _os_
end

function SSubmit2Npc:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.submittype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_availableids=0,_os_null_availableids
	_os_null_availableids, sizeof_availableids = _os_: uncompact_uint32(sizeof_availableids)
	for k = 1,sizeof_availableids do
		self.availableids[k] = _os_:unmarshal_int32()
	end
	self.availablepos = _os_:unmarshal_int32()
	return _os_
end

return SSubmit2Npc
