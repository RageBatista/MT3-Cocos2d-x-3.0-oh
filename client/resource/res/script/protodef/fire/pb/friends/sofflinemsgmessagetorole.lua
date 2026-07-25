require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
require "protodef.rpcgen.fire.pb.friends.strangermessagebean"
require "protodef.rpcgen.fire.pb.friends.offlinemsgbean"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
SOffLineMsgMessageToRole = {}
SOffLineMsgMessageToRole.__index = SOffLineMsgMessageToRole



SOffLineMsgMessageToRole.PROTOCOL_TYPE = 806537

function SOffLineMsgMessageToRole.Create()
	print("enter SOffLineMsgMessageToRole create")
	return SOffLineMsgMessageToRole:new()
end
function SOffLineMsgMessageToRole:new()
	local self = {}
	setmetatable(self, SOffLineMsgMessageToRole)
	self.type = self.PROTOCOL_TYPE
	self.offlinemsglist = {}

	return self
end
function SOffLineMsgMessageToRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOffLineMsgMessageToRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.offlinemsglist))
	for k,v in ipairs(self.offlinemsglist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SOffLineMsgMessageToRole:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_offlinemsglist=0 ,_os_null_offlinemsglist
	_os_null_offlinemsglist, sizeof_offlinemsglist = _os_: uncompact_uint32(sizeof_offlinemsglist)
	for k = 1,sizeof_offlinemsglist do
		----------------unmarshal bean
		self.offlinemsglist[k]=offLineMsgBean:new()

		self.offlinemsglist[k]:unmarshal(_os_)

	end
	return _os_
end

return SOffLineMsgMessageToRole
