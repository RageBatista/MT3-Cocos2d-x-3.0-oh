require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
require "protodef.rpcgen.fire.pb.talk.displayinfo"
StrangerMessageBean = {}
StrangerMessageBean.__index = StrangerMessageBean


function StrangerMessageBean:new()
	local self = {}
	setmetatable(self, StrangerMessageBean)
	self.friendinfobean = InfoBean:new()
	self.content = "" 
	self.details = {}
	self.displayinfo = {}

	return self
end
function StrangerMessageBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.friendinfobean:marshal(_os_) 
	_os_:marshal_wstring(self.content)

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

function StrangerMessageBean:unmarshal(_os_)
	----------------unmarshal bean

	self.friendinfobean:unmarshal(_os_)

	self.content = _os_:unmarshal_wstring(self.content)
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

return StrangerMessageBean
