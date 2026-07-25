require "utils.tableutil"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
CTransChatMessage2Serv = {}
CTransChatMessage2Serv.__index = CTransChatMessage2Serv



CTransChatMessage2Serv.PROTOCOL_TYPE = 792433

function CTransChatMessage2Serv.Create()
	print("enter CTransChatMessage2Serv create")
	return CTransChatMessage2Serv:new()
end
function CTransChatMessage2Serv:new()
	local self = {}
	setmetatable(self, CTransChatMessage2Serv)
	self.type = self.PROTOCOL_TYPE
	self.messagetype = 0
	self.message = "" 
	self.checkshiedmessage = "" 
	self.displayinfos = {}
	self.funtype = 0
	self.taskid = 0

	return self
end
function CTransChatMessage2Serv:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTransChatMessage2Serv:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.messagetype)
	_os_:marshal_wstring(self.message)
	_os_:marshal_wstring(self.checkshiedmessage)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.displayinfos))
	for k,v in ipairs(self.displayinfos) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.funtype)
	_os_:marshal_int32(self.taskid)
	return _os_
end

function CTransChatMessage2Serv:unmarshal(_os_)
	self.messagetype = _os_:unmarshal_int32()
	self.message = _os_:unmarshal_wstring(self.message)
	self.checkshiedmessage = _os_:unmarshal_wstring(self.checkshiedmessage)
	----------------unmarshal vector
	local sizeof_displayinfos=0,_os_null_displayinfos
	_os_null_displayinfos, sizeof_displayinfos = _os_: uncompact_uint32(sizeof_displayinfos)
	for k = 1,sizeof_displayinfos do
		----------------unmarshal bean
		self.displayinfos[k]=DisplayInfo:new()

		self.displayinfos[k]:unmarshal(_os_)

	end
	self.funtype = _os_:unmarshal_int32()
	self.taskid = _os_:unmarshal_int32()
	return _os_
end

return CTransChatMessage2Serv
