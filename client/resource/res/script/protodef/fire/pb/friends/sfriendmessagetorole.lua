require "utils.tableutil"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
SFriendMessageToRole = {}
SFriendMessageToRole.__index = SFriendMessageToRole



SFriendMessageToRole.PROTOCOL_TYPE = 806436

function SFriendMessageToRole.Create()
	print("enter SFriendMessageToRole create")
	return SFriendMessageToRole:new()
end
function SFriendMessageToRole:new()
	local self = {}
	setmetatable(self, SFriendMessageToRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.content = "" 
	self.rolelevel = 0
	self.details = {}
	self.displayinfo = {}

	return self
end
function SFriendMessageToRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFriendMessageToRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.content)
	_os_:marshal_short(self.rolelevel)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.details))
	for k,v in ipairs(self.details) do
		_os_: marshal_octets(v)
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.displayinfo))
	for k,v in ipairs(self.displayinfo) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SFriendMessageToRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.content = _os_:unmarshal_wstring(self.content)
	self.rolelevel = _os_:unmarshal_short()
	----------------unmarshal vector
	local sizeof_details=0,_os_null_details
	_os_null_details, sizeof_details = _os_: uncompact_uint32(sizeof_details)
	for k = 1,sizeof_details do
		self.details[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.details[k])
	end
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

return SFriendMessageToRole
