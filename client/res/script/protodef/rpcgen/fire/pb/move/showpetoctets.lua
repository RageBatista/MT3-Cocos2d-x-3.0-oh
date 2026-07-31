require "utils.tableutil"
ShowPetOctets = {}
ShowPetOctets.__index = ShowPetOctets


function ShowPetOctets:new()
	local self = {}
	setmetatable(self, ShowPetOctets)
	self.showpetid = 0
	self.showpetname = "" 
	self.petcoloursndsize = 0
	self.showskilleffect = 0
	self.evolvelevel = 0

	return self
end
function ShowPetOctets:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.showpetid)
	_os_:marshal_wstring(self.showpetname)
	_os_:marshal_short(self.petcoloursndsize)
	_os_:marshal_char(self.showskilleffect)
	_os_:marshal_char(self.evolvelevel)
	return _os_
end

function ShowPetOctets:unmarshal(_os_)
	self.showpetid = _os_:unmarshal_int32()
	self.showpetname = _os_:unmarshal_wstring(self.showpetname)
	self.petcoloursndsize = _os_:unmarshal_short()
	self.showskilleffect = _os_:unmarshal_char()
	self.evolvelevel = _os_:unmarshal_char()
	return _os_
end

return ShowPetOctets
