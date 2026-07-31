require "utils.tableutil"
STransChatMessageNotify2Client = {}
STransChatMessageNotify2Client.__index = STransChatMessageNotify2Client



STransChatMessageNotify2Client.PROTOCOL_TYPE = 792437

function STransChatMessageNotify2Client.Create()
	print("enter STransChatMessageNotify2Client create")
	return STransChatMessageNotify2Client:new()
end
function STransChatMessageNotify2Client:new()
	local self = {}
	setmetatable(self, STransChatMessageNotify2Client)
	self.type = self.PROTOCOL_TYPE
	self.messageid = 0
	self.npcbaseid = 0
	self.parameters = {}

	return self
end
function STransChatMessageNotify2Client:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STransChatMessageNotify2Client:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.messageid)
	_os_:marshal_int32(self.npcbaseid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.parameters))
	for k,v in ipairs(self.parameters) do
		_os_: marshal_octets(v)
	end

	return _os_
end

function STransChatMessageNotify2Client:unmarshal(_os_)
	self.messageid = _os_:unmarshal_int32()
	self.npcbaseid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_parameters=0,_os_null_parameters
	_os_null_parameters, sizeof_parameters = _os_: uncompact_uint32(sizeof_parameters)
	for k = 1,sizeof_parameters do
		self.parameters[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.parameters[k])
	end
	return _os_
end

return STransChatMessageNotify2Client
