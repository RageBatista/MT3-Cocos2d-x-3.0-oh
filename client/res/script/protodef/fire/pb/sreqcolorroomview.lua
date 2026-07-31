require "utils.tableutil"
require "protodef.rpcgen.fire.pb.rolecolortype"
SReqColorRoomView = {}
SReqColorRoomView.__index = SReqColorRoomView



SReqColorRoomView.PROTOCOL_TYPE = 786535

function SReqColorRoomView.Create()
	print("enter SReqColorRoomView create")
	return SReqColorRoomView:new()
end
function SReqColorRoomView:new()
	local self = {}
	setmetatable(self, SReqColorRoomView)
	self.type = self.PROTOCOL_TYPE
	self.nummax = 0
	self.rolecolortypelist = {}

	return self
end
function SReqColorRoomView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqColorRoomView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.nummax)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolecolortypelist))
	for k,v in ipairs(self.rolecolortypelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SReqColorRoomView:unmarshal(_os_)
	self.nummax = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_rolecolortypelist=0 ,_os_null_rolecolortypelist
	_os_null_rolecolortypelist, sizeof_rolecolortypelist = _os_: uncompact_uint32(sizeof_rolecolortypelist)
	for k = 1,sizeof_rolecolortypelist do
		----------------unmarshal bean
		self.rolecolortypelist[k]=RoleColorType:new()

		self.rolecolortypelist[k]:unmarshal(_os_)

	end
	return _os_
end

return SReqColorRoomView
