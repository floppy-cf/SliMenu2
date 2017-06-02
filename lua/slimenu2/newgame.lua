surface.CreateFont("slimenu2_newgame_title",{
	font = "Roboto",
	size = 64,
	weight = 400,
})

local stripes = surface.GetTextureID"vgui/alpha-back"
local gradient = surface.GetTextureID"vgui/gradient-l"

local function NewGameMenu()
	if IsValid(_G.pnlNewGame) then return end

	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW()-600,ScrH()-300)
	frame:Center()
	frame:SetTitle("")
	frame:DockPadding(4,76,4,4)
	frame.btnMinim:SetVisible(false)
	frame.btnMaxim:SetVisible(false)

	local pos = frame:GetWide()

	function frame:Paint(w,h)
		pos = pos+0.1

		draw.RoundedBox(0,0,0,w,h,Color(32,32,32,200))
		for i = 1,2 do
			draw.RoundedBox(0,0,70+i,w,2,Color(0,0,0,100))
		end

		surface.SetTexture(stripes)
		surface.SetDrawColor(0,64,128,255)
		surface.DrawTexturedRectUV( -(pos%128),0,pos+(pos%128),72, 0,0,-(pos+(pos%128))/128,1 )
		surface.SetTexture(gradient)
		surface.SetDrawColor(0,128,255,255)
		surface.DrawTexturedRect(0,0,w/2,72)
		draw.DrawText("New Game","slimenu2_newgame_title",8,4,Color(255,255,255))
	end

	local menu = vgui.Create("DPanel",frame)
	local select = vgui.Create("DPanel",frame)

	menu:Dock(RIGHT)
	menu:SetWide(300)
	menu:DockMargin(4,4,4,4)

	local start = vgui.Create("StartGame",menu)
	start:Dock(BOTTOM)
	start:SetTall(64)

	select:Dock(FILL)
	select:DockMargin(4,4,4,4)

	local maps = vgui.Create("MapListIcons",select)
	maps:SetController(start)
	maps:Setup()
	maps:Dock(FILL)

	local options = vgui.Create("MapListOptions",menu)
	options:Dock(FILL)
	options:SetupMultiPlayer()

	_G.pnlNewGame = frame
end

concommand.Add( "menu_play", NewGameMenu )