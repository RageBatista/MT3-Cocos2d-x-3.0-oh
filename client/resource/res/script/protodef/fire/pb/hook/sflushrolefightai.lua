require "utils.tableutil"
SFlushRoleFightAI = {}
SFlushRoleFightAI.__index = SFlushRoleFightAI



SFlushRoleFightAI.PROTOCOL_TYPE = 810343

function SFlushRoleFightAI.Create()
	print("enter SFlushRoleFightAI create")
	return SFlushRoleFightAI:new()
end
function SFlushRoleFightAI:new()
	local self = {}
	setmetatable(self, SFlushRoleFightAI)
	self.type = self.PROTOCOL_TYPE
	self.fightaiids = {}

	return self
end
function SFlushRoleFightAI:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFlushRoleFightAI:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.fightaiids))
	for k,v in ipairs(self.fightaiids) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SFlushRoleFightAI:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_fightaiids=0,_os_null_fightaiids
	_os_null_fightaiids, sizeof_fightaiids = _os_: uncompact_uint32(sizeof_fightaiids)
	for k = 1,sizeof_fightaiids do
		self.fightaiids[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SFlushRoleFightAI
