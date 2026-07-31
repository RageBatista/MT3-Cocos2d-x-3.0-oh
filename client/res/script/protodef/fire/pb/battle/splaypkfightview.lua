require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.qcroleinfodes"
require "protodef.rpcgen.fire.pb.battle.qcroleinfowatchdes"
SPlayPKFightView = {}
SPlayPKFightView.__index = SPlayPKFightView



SPlayPKFightView.PROTOCOL_TYPE = 793684

function SPlayPKFightView.Create()
	print("enter SPlayPKFightView create")
	return SPlayPKFightView:new()
end
function SPlayPKFightView:new()
	local self = {}
	setmetatable(self, SPlayPKFightView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.school = 0
	self.levelindex = 0
	self.rolelist = {}
	self.rolewatchlist = {}

	return self
end
function SPlayPKFightView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPlayPKFightView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.levelindex)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.rolelist))
	for k,v in ipairs(self.rolelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.rolewatchlist))
	for k,v in ipairs(self.rolewatchlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SPlayPKFightView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.levelindex = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_rolelist=0,_os_null_rolelist
	_os_null_rolelist, sizeof_rolelist = _os_: uncompact_uint32(sizeof_rolelist)
	for k = 1,sizeof_rolelist do
		----------------unmarshal bean
		self.rolelist[k]=QCRoleInfoDes:new()

		self.rolelist[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_rolewatchlist=0,_os_null_rolewatchlist
	_os_null_rolewatchlist, sizeof_rolewatchlist = _os_: uncompact_uint32(sizeof_rolewatchlist)
	for k = 1,sizeof_rolewatchlist do
		----------------unmarshal bean
		self.rolewatchlist[k]=QCRoleInfoWatchDes:new()

		self.rolewatchlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SPlayPKFightView
