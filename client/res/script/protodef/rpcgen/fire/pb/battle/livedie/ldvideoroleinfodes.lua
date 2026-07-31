require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.livedie.ldroleinfodes"
require "protodef.rpcgen.fire.pb.battle.livedie.ldteamroleinfodes"
LDVideoRoleInfoDes = {}
LDVideoRoleInfoDes.__index = LDVideoRoleInfoDes


function LDVideoRoleInfoDes:new()
	local self = {}
	setmetatable(self, LDVideoRoleInfoDes)
	self.role1 = LDRoleInfoDes:new()
	self.role2 = LDRoleInfoDes:new()
	self.teamlist1 = {}
	self.teamlist2 = {}
	self.battleresult = 0
	self.rosenum = 0
	self.roseflag = 0
	self.videoid = "" 

	return self
end
function LDVideoRoleInfoDes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.role1:marshal(_os_) 
	----------------marshal bean
	self.role2:marshal(_os_) 

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.teamlist1))
	for k,v in ipairs(self.teamlist1) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.teamlist2))
	for k,v in ipairs(self.teamlist2) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.battleresult)
	_os_:marshal_int32(self.rosenum)
	_os_:marshal_int32(self.roseflag)
	_os_:marshal_wstring(self.videoid)
	return _os_
end

function LDVideoRoleInfoDes:unmarshal(_os_)
	----------------unmarshal bean

	self.role1:unmarshal(_os_)

	----------------unmarshal bean

	self.role2:unmarshal(_os_)

	----------------unmarshal vector
	local sizeof_teamlist1=0,_os_null_teamlist1
	_os_null_teamlist1, sizeof_teamlist1 = _os_: uncompact_uint32(sizeof_teamlist1)
	for k = 1,sizeof_teamlist1 do
		----------------unmarshal bean
		self.teamlist1[k]=LDTeamRoleInfoDes:new()

		self.teamlist1[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_teamlist2=0,_os_null_teamlist2
	_os_null_teamlist2, sizeof_teamlist2 = _os_: uncompact_uint32(sizeof_teamlist2)
	for k = 1,sizeof_teamlist2 do
		----------------unmarshal bean
		self.teamlist2[k]=LDTeamRoleInfoDes:new()

		self.teamlist2[k]:unmarshal(_os_)

	end
	self.battleresult = _os_:unmarshal_int32()
	self.rosenum = _os_:unmarshal_int32()
	self.roseflag = _os_:unmarshal_int32()
	self.videoid = _os_:unmarshal_wstring(self.videoid)
	return _os_
end

return LDVideoRoleInfoDes
