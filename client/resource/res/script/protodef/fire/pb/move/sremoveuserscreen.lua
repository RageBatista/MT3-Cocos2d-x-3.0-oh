require "utils.tableutil"
SRemoveUserScreen = {}
SRemoveUserScreen.__index = SRemoveUserScreen



SRemoveUserScreen.PROTOCOL_TYPE = 790438

function SRemoveUserScreen.Create()
	print("enter SRemoveUserScreen create")
	return SRemoveUserScreen:new()
end
function SRemoveUserScreen:new()
	local self = {}
	setmetatable(self, SRemoveUserScreen)
	self.type = self.PROTOCOL_TYPE
	self.roleids = {}
	self.npcids = {}

	return self
end
function SRemoveUserScreen:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemoveUserScreen:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.roleids))
	for k,v in ipairs(self.roleids) do
		_os_:marshal_int64(v)
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.npcids))
	for k,v in ipairs(self.npcids) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRemoveUserScreen:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_roleids=0 ,_os_null_roleids
	_os_null_roleids, sizeof_roleids = _os_: uncompact_uint32(sizeof_roleids)
	for k = 1,sizeof_roleids do
		self.roleids[k] = _os_:unmarshal_int64()
	end
	----------------unmarshal list
	local sizeof_npcids=0 ,_os_null_npcids
	_os_null_npcids, sizeof_npcids = _os_: uncompact_uint32(sizeof_npcids)
	for k = 1,sizeof_npcids do
		self.npcids[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return SRemoveUserScreen
