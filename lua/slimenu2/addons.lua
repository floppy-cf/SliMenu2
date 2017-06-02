surface.CreateFont("slimenu2_addons_title",{
	font = "Roboto",
	size = 64,
	weight = 400,
})

local stripes = surface.GetTextureID"vgui/alpha-back"
local gradient = surface.GetTextureID"vgui/gradient-l"

local function AddonsMenu()
	if IsValid(_G.pnlAddons) then return end

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
		surface.SetDrawColor(0,64,0,255)
		surface.DrawTexturedRectUV( -(pos%128),0,pos+(pos%128),72, 0,0,-(pos+(pos%128))/128,1 )
		surface.SetTexture(gradient)
		surface.SetDrawColor(0,128,0,255)
		surface.DrawTexturedRect(0,0,w/2,72)
		draw.DrawText("Addons","slimenu2_addons_title",8,4,Color(255,255,255))
	end

	local menu = vgui.Create("DPanel",frame)
	local scroll = vgui.Create("DScrollPanel",frame)

	menu:Dock(LEFT)
	menu:SetWide(200)
	menu:DockMargin(4,4,4,4)

	scroll:Dock(FILL)
	scroll:DockMargin(4,4,4,4)

	local function CreateAddonInfo(data)
		local pnl = vgui.Create("DPanel")
		pnl:SetTall(128)
		pnl:Dock(TOP)
		pnl:DockMargin(0,0,4,4)
		pnl:SetBackgroundColor(data.mounted and Color(100,200,100) or Color(255,255,255))

		local img = vgui.Create("DImage",pnl)
		img:Dock(LEFT)
		img:SetWide(128)
		img:SetTall(128)
		img:SetImage("slimenu2/no_icon.png")

		local name = vgui.Create("DLabel",pnl)
		name:SetText(data.title or data.file)
		name:SetFont("DermaLarge")
		name:SetColor(Color(0,0,0))
		name:Dock(TOP)
		name:SetTall(32)
		name:DockMargin(2,0,0,0)

		local div = vgui.Create("EditablePanel",pnl)
		div:Dock(TOP)
		div:SetTall(64)

		local mnt = vgui.Create("DButton",pnl)
		mnt:SetTall(32)
		mnt:SetWide(128)
		mnt:Dock(RIGHT)
		mnt:DockMargin(4,0,0,0)
		mnt:SetIcon(data.mounted and "icon16/cross.png" or "icon16/tick.png")
		mnt:SetText(data.mounted and "Disable" or "Enable")
		mnt.DoClick = function(s)
			print("[Addon Mount]",data.file,!data.mounted)
			local old = steamworks.ShouldMountAddon(data.wsid)
			steamworks.SetShouldMountAddon(data.wsid,!data.mounted)
			isours = true steamworks.ApplyAddons() isours = true
			local new = steamworks.ShouldMountAddon(data.wsid)

			if old==new then
				print("Warning: ","could not toggle",data.file)
			else
				data.mounted = new

				if new == true then
					mnt:SetIcon("icon16/cross.png")
					mnt:SetText("Disable")
					pnl:SetBackgroundColor(Color(100,200,100))
				else
					mnt:SetIcon("icon16/tick.png")
					mnt:SetText("Enable")
					pnl:SetBackgroundColor(Color(255,255,255))
				end
			end
		end

		local rem = vgui.Create("DButton",pnl)
		rem:SetTall(32)
		rem:SetWide(128)
		rem:Dock(RIGHT)
		rem:SetIcon("icon16/delete.png")
		rem:SetText("Unsubscribe")
		rem.DoClick = function(s)
			print("Unsubscribe",data.wsid)
			steamworks.Unsubscribe(data.wsid)
			pnl:Remove()
			scroll:PerformLayout()
		end

		local ws = vgui.Create("DButton",pnl)
		ws:SetTall(32)
		ws:SetWide(128)
		ws:Dock(LEFT)
		ws:SetIcon("icon16/link_go.png")
		ws:SetText("Workshop")
		ws.DoClick = function(s)
			gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id="..data.wsid)
		end

		scroll:Add(pnl)
	end

	local enable = vgui.Create("DButton",menu)
	enable:SetText("#addons.enableall")
	enable:SetIcon'icon16/tick.png'
	enable:Dock(TOP)
	enable:SetTall(32)
	function enable.DoClick(btn)
		for k,v in next,engine.GetAddons() do
			steamworks.SetShouldMountAddon(v.wsid or v.file,true)
		end
		isours = true
		steamworks.ApplyAddons()
		isours = true

		scroll:Clear()
		local t=engine.GetAddons()
		table.sort(t,function(a,b)
			if a.mounted==b.mounted then
				if a.wsid and b.wsid then
					return a.wsid<b.wsid
				elseif a.title and b.title then
					return a.title<b.title
				else
					return a.file<b.file
				end
			else
				return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
			end
		end)
		for _,data in next,t do
			CreateAddonInfo(data)
		end
	end

	local disable = vgui.Create("DButton",menu)
	disable:SetText("#addons.disableall")
	disable:SetIcon'icon16/cross.png'
	disable:Dock(TOP)
	disable:SetTall(32)
	function disable.DoClick(btn)
		for k,v in next,engine.GetAddons() do
			steamworks.SetShouldMountAddon(v.wsid or v.file,false)
		end
		isours = true
		steamworks.ApplyAddons()
		isours = true

		scroll:Clear()
		local t=engine.GetAddons()
		table.sort(t,function(a,b)
			if a.mounted==b.mounted then
				if a.wsid and b.wsid then
					return a.wsid<b.wsid
				elseif a.title and b.title then
					return a.title<b.title
				else
					return a.file<b.file
				end
			else
				return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
			end
		end)
		for _,data in next,t do
			CreateAddonInfo(data)
		end
	end

	local t=engine.GetAddons()
	table.sort(t,function(a,b)
		if a.mounted==b.mounted then
			if a.wsid and b.wsid then
				return a.wsid<b.wsid
			elseif a.title and b.title then
				return a.title<b.title
			else
				return a.file<b.file
			end
		else
			return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
		end
	end)
	for _,data in next,t do
		CreateAddonInfo(data)
	end

	_G.pnlAddons = frame
end

concommand.Add( "menu_addons", AddonsMenu )