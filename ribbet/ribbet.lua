--Löve's only (maybe) frog-esque named ribbon library by Apel
local MetaRibbet = {}
MetaRibbet.__index = MetaRibbet

local Ribbet = setmetatable({}, MetaRibbet)
Ribbet.__index = Ribbet

--config-----------------------------------------------------------------------------------------------------------
Ribbet.path = "ribbet"--path to library
Ribbet.pathFont = Ribbet.path.."/arial.ttf"--path to font
Ribbet.fontSize = 14
Ribbet.textCushion = 6--white space surrounding letters
Ribbet.flyWidth = 100
-------------------------------------------------------------------------------------------------------------------

--used for all text based draw calls
Ribbet.textFont = love.graphics.newFont(Ribbet.pathFont, Ribbet.fontSize, "mono")
Ribbet.textObj = love.graphics.newText(Ribbet.textFont, "croak!")
Ribbet.textHeight = Ribbet.textObj:getHeight()

Ribbet.imageFile = love.graphics.newImage(Ribbet.path.."/ribbet.png")
--ex. ribbet() returns the "child" inst
--this allows for mutiple ribbons for swapping if need be
function MetaRibbet:__call()
	local inst = setmetatable({}, self)
	inst.tabs = {}--top tabs
	inst.activeFly = nil--the active fly
	inst.lastTab = nil
	return inst
end

--returns the height of the header ribbon which is also used for height spacing on all tabs
function Ribbet.getRibbetHeight()
	return Ribbet.textHeight + Ribbet.textCushion
end

function Ribbet.buildFly(t)
	assert(type(t) == "table", "buildFly First value is required and must be a table!")
	local _fly = t
	_fly.x = 0
	_fly.y = Ribbet.getRibbetHeight()
	_fly.height = 0
	_fly.width = Ribbet.flyWidth

	for i, v in pairs(_fly) do
		if type(v) == "table" then
			_fly.height = _fly.height + Ribbet.getRibbetHeight()
			--set fly width if bigger than base
			if v.name ~= nil then
				local _t = v.hotKey_display ~= nil and v.name.."    "..v.hotKey_display or v.name
				Ribbet.textObj:set(_t)
				if Ribbet.textObj:getWidth() + Ribbet.textCushion*2 > _fly.width then
					_fly.width = Ribbet.textObj:getWidth() + Ribbet.textCushion*2
				end
			end
		end
	end

	return _fly
end

--builds tab for use in tabs - flies and fleas
function Ribbet.buildTab(_name, t)
	if t ~= nil then assert(type(t) == "table", "buildTab Second value must be a table") end
	local _tab = t or {}
	_tab.name = _name
	--if has hotkey activator - set display text for flys
	if _tab.hotKey ~= nil then
		local _display = ""
		for i,v in pairs(_tab.hotKey) do
			_display = i==1 and v or v.."+".._display
		end
		_tab.hotKey_display = _display 
	end
	return _tab
end

--function adds tab to main tabs/ribbon
function Ribbet:addTab(_tab)
	table.insert(self.tabs, _tab)
end

--perform hotkey action for flys
function Ribbet:activateHotKey(_keyPressed)
	--check main tabs for flys
	for i,v in pairs(self.tabs) do
		if v.fly ~= nil then
			--check all tabs in fly
			for j,z in pairs(v.fly) do
				--match hotkey
				if type(z) == "table" and z.hotKey ~= nil then
					if _keyPressed == z.hotKey[1] then
						--check all pressed requirments match
						for g,p in pairs(z.hotKey) do
							if not love.keyboard.isDown(p) then break end --failed one of the checks continue key loop
							if g == table.maxn(z.hotKey) then
								z.click()
								return true
							end
						end
					end
				end
			end
		end
	end
end

--when click on tab do thing
function Ribbet:click(_x,_y)
	local _tab, _tabX = self:getTab_atPos(_x,_y)
	local _flag = false

	self.activeFly = nil

	if _tab == nil then 
		self.lastTab = nil
		return _flag 
	end

	if _tab.bool ~= nil then
		print(_tab.bool())
	end

	if _tab.click ~= nil then
		_tab:click()
		_flag = true
	elseif _tab.fly ~= nil then
		--fly func
		self.activeFly = _tab.fly
		self.activeFly.x = _tabX
		_flag = true
	end

	if _flag then
		self.lastTab = _tab
	end
	
	return _flag
end

--returns the tab, and a single position value
function Ribbet:getTab_atPos(_mx,_my)
	--find top tab
	local _x, _x2 = 0
	for i, v in pairs(self.tabs) do
		Ribbet.textObj:set(v.name)

		_x2 = _x + Ribbet.textObj:getWidth() + Ribbet.textCushion*2

		if ((_mx > _x) and (_mx < _x2)) and ((_my > 0) and (_my < Ribbet.getRibbetHeight())) then
			return v, _x
		end

		_x = _x2
	end

	local _y, _y2 = 0
	--find flys
	if self.activeFly ~= nil then
		local _fly = self.activeFly
		_x = _fly.x
		_x2 = _x + _fly.width
		_y = _fly.y
		for i, v in pairs(_fly) do
			if type(v) == "table" then
				Ribbet.textObj:set(v.name)

				_y2 = _y + Ribbet.getRibbetHeight()

				if ((_mx > _x) and (_mx < _x2)) and ((_my > _y) and (_my < _y2)) then
					return v, _y
				end

				_y = _y2
			end
		end
	end

	--find fleas

	return nil, nil
end

--draw-------------------------------------------------------------------------------------------------------------------
function Ribbet:draw()
	self:drawRibbon()
	self:drawFly()
end

--the main tabs
function Ribbet:drawRibbon()
	love.graphics.rectangle("fill", 0,0, love.graphics.getWidth(), Ribbet.getRibbetHeight())

	--top tab
	local _x = Ribbet.textCushion
	love.graphics.setColor(0,0,0)
	for i, v in pairs(self.tabs) do
		Ribbet.textObj:set(v.name)

		if (v == self.lastTab) then
			love.graphics.setColor(0,0,35,0.2)
			love.graphics.rectangle("fill", _x-Ribbet.textCushion, 0, Ribbet.textObj:getWidth()+Ribbet.textCushion*2, Ribbet.getRibbetHeight())
			love.graphics.setColor(0,0,0)
		end

		love.graphics.draw(Ribbet.textObj, _x, Ribbet.textCushion/2)
		_x = _x + Ribbet.textObj:getWidth() + Ribbet.textCushion*2
	end
	love.graphics.setColor(1,1,1)
	if Ribbet.imageFile ~= nil then
		love.graphics.draw(Ribbet.imageFile, love.graphics.getWidth()-Ribbet.textCushion-14, Ribbet.textCushion/2)
	end
end

--flies are the drop downs from the main tabs
function Ribbet:drawFly()
	local _fly = self.activeFly
	if _fly == nil then return end
	love.graphics.setColor(0.4,0.4,0.4)
	love.graphics.rectangle("fill", _fly.x-1, _fly.y-1, _fly.width+2, _fly.height+2)
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill", _fly.x, _fly.y, _fly.width, _fly.height)

	local _y = Ribbet.textCushion/2 + Ribbet.getRibbetHeight()
	love.graphics.setColor(0,0,0)
	for i, v in pairs(_fly) do
		if type(v) == "table" then
			Ribbet.textObj:set(v.name)
			love.graphics.draw(Ribbet.textObj, _fly.x + Ribbet.textCushion, _y)
			if v.hotKey_display ~= nil then
				Ribbet.textObj:set(v.hotKey_display)
				love.graphics.draw(Ribbet.textObj, _fly.x + _fly.width- Ribbet.textCushion - Ribbet.textObj:getWidth(), _y)
			end
			_y = _y + Ribbet.getRibbetHeight()
		end
	end
	love.graphics.setColor(1,1,1)
end

return Ribbet
