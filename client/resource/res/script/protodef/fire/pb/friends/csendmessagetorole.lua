require "utils.tableutil"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
CSendMessageToRole = {}
CSendMessageToRole.__index = CSendMessageToRole



CSendMessageToRole.PROTOCOL_TYPE = 806435

function CSendMessageToRole.Create()
	print("enter CSendMessageToRole create")
	return CSendMessageToRole:new()
end
function CSendMessageToRole:new()
	local self = {}
	setmetatable(self, CSendMessageToRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.content = "" 
	self.checkshiedmsg = "" 
	self.displayinfo = {}

	return self
end
function CSendMessageToRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendMessageToRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.content)
	_os_:marshal_wstring(self.checkshiedmsg)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.displayinfo))
	for k,v in ipairs(self.displayinfo) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function CSendMessageToRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.content = _os_:unmarshal_wstring(self.content)
	self.checkshiedmsg = _os_:unmarshal_wstring(self.checkshiedmsg)
	----------------unmarshal vector
	local sizeof_displayinfo=0,_os_null_displayinfo
	_os_null_displayinfo, sizeof_displayinfo = _os_: uncompact_uint32(sizeof_displayinfo)
	for k = 1,sizeof_displayinfo do
		----------------unmarshal bean
		self.displayinfo[k]=DisplayInfo:new()

		self.displayinfo[k]:unmarshal(_os_)

	end
	return _os_
end

return CSendMessageToRole
