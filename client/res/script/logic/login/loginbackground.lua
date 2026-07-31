require "logic.dialog"

loginBg = {}
setmetatable(loginBg, Dialog)
loginBg.__index = loginBg

local spineWidth = 1280
local spineHeight = 810
local maxLoginSpineScale = 0.50

local function calcLoginSpineScale()
	-- 登录背景按屏幕尺寸适配，避免 UI 逻辑尺寸上调导致 Spine 被额外放大
	local screenWidth = Nuclear.GetEngine():GetScreenWidth()
	local screenHeight = Nuclear.GetEngine():GetScreenHeight()
	if screenWidth <= 0 then
		screenWidth = spineWidth
	end
	if screenHeight <= 0 then
		screenHeight = spineHeight
	end
	local xscale = screenWidth / spineWidth
	local yscale = screenHeight / spineHeight
	local scale = math.max(xscale, yscale)
	-- 旧版本视觉基线约为 0.8，显式上限避免登录 Spine 在高分屏继续放大
	if scale > maxLoginSpineScale then
		scale = maxLoginSpineScale
	end
	return scale
end

local _instance -- 登录背景单例
function loginBg.getInstance()
	if not _instance then
		_instance = loginBg:new() -- 首次访问时创建实例
		_instance:OnCreate() -- 立即完成窗口和动画初始化
	end
	return _instance
end

function loginBg.getInstanceAndShow()
	if not _instance then
		_instance = loginBg:new() -- 不存在时补建实例
		_instance:OnCreate() -- 首次显示前完成初始化
	else
		_instance:SetVisible(true) -- 已存在则直接显隐切回显示
	end
	return _instance
end

function loginBg.getInstanceNotCreate()
	return _instance
end

function loginBg.DestroyDialog()
	if _instance then
        if _instance.spine then
            _instance.spine:delete() -- 先释放 Spine 资源，避免渲染回调悬挂
            _instance.spine = nil -- 清掉引用，防止后续重复访问
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose() -- 真关闭模式下走 Dialog 关闭流程
			_instance = nil -- 彻底销毁单例
		else
			_instance:ToggleOpenClose() -- 仅隐藏模式下切到不可见
		end
	end
end

function loginBg.ToggleOpenClose()
	if not _instance then
		_instance = loginBg:new() -- 尚未创建时按打开处理
		_instance:OnCreate() -- 打开时初始化背景和动画
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false) -- 当前可见则隐藏
		else
			_instance:SetVisible(true) -- 当前隐藏则重新显示
		end
	end
end

function loginBg.GetLayoutFileName()
	return "gugedonghua.layout" -- 登录背景对应的 CEGUI 布局文件
end

function loginBg:new()
	local self = {}
	self = Dialog:new() -- 先构造基类对象
	setmetatable(self, loginBg) -- 再挂到 loginBg 元表
	return self
end

function loginBg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.bg = winMgr:getWindow("gugedonghua") -- 旧逻辑同样挂到登录背景窗口
	local pos = self.bg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x, pos.y)
	self.spine = UISpineSprite:new("denglu") -- 旧流程仍使用默认登录 Spine
	self.spine:SetUILocation(loc)
	self.bg:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, loginBg.performPostRenderFunctions)) -- 维持同一套后处理渲染入口
	self.spine:SetUIScale(calcLoginSpineScale())
end

function loginBg:showOld()
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.bg = winMgr:getWindow("gugedonghua")
	local pos = self.bg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x, pos.y)
	self.spine = UISpineSprite:new("denglu")
	self.spine:SetUILocation(loc)
	self.bg:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, loginBg.performPostRenderFunctions))
	self.spine:SetUIScale(calcLoginSpineScale())
end

function loginBg:showbg(bgname)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.bg = winMgr:getWindow("gugedonghua")
	local pos = self.bg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x-85, pos.y-30)
	self.spine = UISpineSprite:new(bgname)
	self.spine:SetUILocation(loc)
	self.bg:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, loginBg.performPostRenderFunctions))
	self.spine:SetUIScale(calcLoginSpineScale())
	self.spine:PlayAction(eActionStand)
end
function loginBg.performPostRenderFunctions(id)
	if _instance and _instance.spine then
		_instance.spine:RenderUISprite() -- 在 UI 后处理阶段手动绘制 Spine
	end
end

return loginBg
