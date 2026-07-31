require "utils.tableutil"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
STransChatMessage2Client = {}
STransChatMessage2Client.__index = STransChatMessage2Client



STransChatMessage2Client.PROTOCOL_TYPE = 792434

function STransChatMessage2Client.Create()
	print("enter STransChatMessage2Client create")
	return STransChatMessage2Client:new()
end
function STransChatMessage2Client:new()
	local self = {}
	setmetatable(self, STransChatMessage2Client)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 
	self.shapeid = 0
	self.titleid = 0
	self.messagetype = 0
	self.message = "" 
	self.displayinfos = {}

	return self
end
function STransChatMessage2Client:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STransChatMessage2Client:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shapeid)
	_os_:marshal_int32(self.titleid)
	_os_:marshal_int32(self.messagetype)
	_os_:marshal_wstring(self.message)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.displayinfos))
	for k,v in ipairs(self.displayinfos) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function STransChatMessage2Client:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shapeid = _os_:unmarshal_int32()
	self.titleid = _os_:unmarshal_int32()
	self.messagetype = _os_:unmarshal_int32()
	self.message = _os_:unmarshal_wstring(self.message)
	----------------unmarshal vector
	local sizeof_displayinfos=0,_os_null_displayinfos
	_os_null_displayinfos, sizeof_displayinfos = _os_: uncompact_uint32(sizeof_displayinfos)
	for k = 1,sizeof_displayinfos do
		----------------unmarshal bean
		self.displayinfos[k]=DisplayInfo:new()

		self.displayinfos[k]:unmarshal(_os_)

	end
	return _os_
end

return STransChatMessage2Client
