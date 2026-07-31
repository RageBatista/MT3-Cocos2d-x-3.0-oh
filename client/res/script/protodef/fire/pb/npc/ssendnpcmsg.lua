require "utils.tableutil"
SSendNpcMsg = {}
SSendNpcMsg.__index = SSendNpcMsg



SSendNpcMsg.PROTOCOL_TYPE = 795454

function SSendNpcMsg.Create()
	print("enter SSendNpcMsg create")
	return SSendNpcMsg:new()
end
function SSendNpcMsg:new()
	local self = {}
	setmetatable(self, SSendNpcMsg)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.npcid = 0
	self.msgid = 0
	self.args = {}

	return self
end
function SSendNpcMsg:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendNpcMsg:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.npcid)
	_os_:marshal_int32(self.msgid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.args))
	for k,v in ipairs(self.args) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function SSendNpcMsg:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.npcid = _os_:unmarshal_int32()
	self.msgid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_args=0,_os_null_args
	_os_null_args, sizeof_args = _os_: uncompact_uint32(sizeof_args)
	for k = 1,sizeof_args do
		self.args[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return SSendNpcMsg
