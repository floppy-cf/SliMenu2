local easteregg = CreateClientConVar("___________________slimenu2_easteregg","0",true,false):GetBool()

local MenuGradient = Material( "../html/img/gradient.png", "nocull smooth" )

local Images = {}

local tmpbg = table.Random(file.Find("backgrounds/*.*", "GAME" ))

local mat = Material("../backgrounds/"..tmpbg,"nocull smooth")

local Active = {
		Ratio = mat:GetInt( "$realwidth" ) / mat:GetInt( "$realheight" ),
		Size = 1,
		Angle = 0,
		AngleVel = -( 5 / 30 ),
		SizeVel = ( 0.3 / 30 ),
		Alpha = 255,
		DieTime = 30,
		mat = mat
	}
local Outgoing = nil

local function Think( tbl )

	tbl.Angle = tbl.Angle + ( tbl.AngleVel * FrameTime() )
	tbl.Size = tbl.Size + ( ( tbl.SizeVel / tbl.Size) * FrameTime() )

	if ( tbl.AlphaVel ) then
		tbl.Alpha = tbl.Alpha - tbl.AlphaVel * FrameTime()
	end

	if ( tbl.DieTime > 0 ) then
		tbl.DieTime = tbl.DieTime - FrameTime()

		if ( tbl.DieTime <= 0 ) then
			ChangeBackground()
		end
	end

end

local function Render( tbl )

	surface.SetMaterial( tbl.mat )
	surface.SetDrawColor( 255, 255, 255, tbl.Alpha )

	local w = ScrH() * tbl.Size * tbl.Ratio
	local h = ScrH() * tbl.Size

	local x = ScrW() * 0.5
	local y = ScrH() * 0.5

	surface.DrawTexturedRectRotated( x, y, w, h, tbl.Angle )

end

--Easter Egg defines
local columns = ScrW()/8
local drops = {};
for i=0,columns do drops[i] = ScrH() end

function DrawBackground()

	if ( !IsInGame() ) then
		draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0))
		if easteregg == true then
			-- If you're snooping around at the code, this is a JS to Lua translation of the 8bit rain effect done on FLPY-CF's site: https://xn--6s8h.cf

			draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0,128))
			for _i=1,2 do
				for i=0,columns do
					--draw.RoundedBox(0,(i*8)-8,(drops[i]*8)-8,8,8,rcol)
					for a=0,16 do
						local rcol = ColorRand()
						draw.RoundedBox(0,(i*8)-8,(drops[i]*8)-8-(8*a),8,8,Color(rcol.r,rcol.g,rcol.b,255-(16*a)))
					end
					if drops[i]*8 > ScrH() && math.Rand(0,1) > 0.975 then drops[i] = 0 end
					drops[i] = drops[i]+1
				end
			end

			draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0,128))
		else
			if ( Active ) then
				Think( Active )
				Render( Active )
			end

			if ( Outgoing ) then

				Think( Outgoing )
				Render( Outgoing )

				if ( Outgoing.Alpha <= 0 ) then
					Outgoing = nil
				end

			end
		end
	end

	if easteregg==false then
		surface.SetMaterial( MenuGradient )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 0, 0, 1024, ScrH() )
	end

end

function ClearBackgroundImages( img )

	Images = {}

end

function AddBackgroundImage( img )

	table.insert( Images, img )

end

local LastGamemode = "none"

function ChangeBackground()
	if easteregg then return end

	local img = table.Random( Images )
	
	if ( !img ) then return end

	Outgoing = Active
	if ( Outgoing ) then
		Outgoing.AlphaVel = 255
	end

	local mat = Material( img, "nocull smooth" )
	if ( !mat || mat:IsError() ) then return end

	Active = {
		Ratio = mat:GetInt( "$realwidth" ) / mat:GetInt( "$realheight" ),
		Size = 1,
		Angle = 0,
		AngleVel = -( 5 / 30 ),
		SizeVel = ( 0.3 / 30 ),
		Alpha = 255,
		DieTime = 30,
		mat = mat
	}

	if ( Active.Ratio < ScrW() / ScrH() ) then

		Active.Size = Active.Size + ( ( ScrW() / ScrH() ) - Active.Ratio )

	end

end

----

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	ChangeBackground()
end

function PANEL:ScreenshotScan( folder )
	local bReturn = false

	local Screenshots = file.Find( folder .. "*.*", "GAME" )
	for k, v in RandomPairs( Screenshots ) do
		AddBackgroundImage( folder .. v )
		bReturn = true
	end

	return bReturn
end

function PANEL:Paint()
	DrawBackground()

	if ( self.IsInGame != IsInGame() ) then

		self.IsInGame = IsInGame()

		if ( self.IsInGame ) then
			if ( IsValid( self.InnerPanel ) ) then self.InnerPanel:Remove() end
		end

	end
end


function PANEL:RefreshGamemodes()
	local json = util.TableToJSON( engine.GetGamemodes() )
	self:UpdateBackgroundImages()
end

function PANEL:UpdateBackgroundImages()
	ClearBackgroundImages()

	if ( !self:ScreenshotScan( "gamemodes/" .. engine.ActiveGamemode() .. "/backgrounds/" ) ) then
		self:ScreenshotScan( "backgrounds/" )
	end

	ChangeBackground()
end

vgui.Register( "menu2_background", PANEL, "EditablePanel" )