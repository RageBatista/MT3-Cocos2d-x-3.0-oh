
Taskbuff = {}
Taskbuff.__index = Taskbuff


function Taskbuff:new()
	local self = {}
	setmetatable(self, Taskbuff)
	
	self.nBuffId = -1
	self.nTaskType =-1
	
	self.nUpdateSpaceDt = 0 --second
	self.nUpdateSpace =1
	return self
end

function Taskbuff:update(delta)
	local dt = delta/1000
	self.nUpdateSpaceDt = self.nUpdateSpaceDt + dt
	if self.nUpdateSpaceDt <self.nUpdateSpace then
		return 
	end
	self.nUpdateSpaceDt = 0
	require("logic.task.taskhelperrepeat").RefreshTaskBuffChuanShuo(nBuffId)
	
end


function Taskbuff:beginBuff()
	require("logic.task.taskhelperrepeat").RefreshTaskBuffChuanShuo(nBuffId)
	
end


function Taskbuff:endBuff()
	require("logic.task.taskhelperrepeat").RefreshTaskBuffChuanShuo(nBuffId)
end


return Taskbuff
