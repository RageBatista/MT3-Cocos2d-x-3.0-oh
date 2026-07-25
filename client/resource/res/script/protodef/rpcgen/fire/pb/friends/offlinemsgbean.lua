require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
require "protodef.rpcgen.fire.pb.friends.strangermessagebean"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
offLineMsgBean = {}
offLineMsgBean.__index = offLineMsgBean


function offLineMsgBean:new()
	local self = {}
	setmetatable(self, offLineMsgBean)
	self.strangermessage = StrangerMessageBean:new()
	self.time = "" 

	return self
end
function offLineMsgBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.strangermessage:marshal(_os_) 
	_os_:marshal_wstring(self.time)
	return _os_
end

function offLineMsgBean:unmarshal(_os_)
	----------------unmarshal bean

	self.strangermessage:unmarshal(_os_)

	self.time = _os_:unmarshal_wstring(self.time)
	return _os_
end

return offLineMsgBean
