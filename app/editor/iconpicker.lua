local rtk = require 'rtk'
local articons = require 'articons'
local reabank = require 'reabank'
local debug = require 'lib.debug'
require 'lib.utils'


local IconPicker = rtk.class('IconPicker')

function IconPicker:initialize()
    self.box = rtk.VBox{lpadding=20, rpadding=20, spacing=20}
    self.popup = rtk.Popup{child=self.box}

    self.icon_filter = self.box:add(
        rtk.Entry{icon='search', placeholder='Filter icons'},
        {halign='center', fillw=true}
    )
    self.top_box = self.box:add(rtk.HBox{spacing=20})
    self.color_box = self.top_box:add(rtk.VBox())
    self.right_box = self.top_box:add(rtk.VBox(), {fillw=true})

    self.icon_box = rtk.FlowBox()
    self.right_box:add(
        rtk.Text{'Icon', bmargin=5},
        {halign='center'}
    )
    self.right_box:add(
        self.icon_box
    )

    self.bottom_box = self.box:add(
        rtk.VBox{spacing=20},
        {fillw=true, fillh=true}
    )
    self.button_box = self.bottom_box:add(
        rtk.VBox{spacing=10},
        {fillw=true}
    )

    self.color_box:add(
        rtk.Text{'Color', bmargin=5},
        {halign='center'}
    )

    for color, value in pairs(reabank.default_colors) do
        local color_button = self.color_box:add(
            rtk.Button{
                label=color,
                color=value,
                minw=150
            }
        )
        color_button.onclick = function()
            self.current_color = color
            self:refresh()
            self:send_change(color, nil)
        end
    end

    self.icon_filter.onchange = function()
        self:refresh()
    end

    self:refresh()
end

function IconPicker:refresh()
    self.icon_box:remove_all()
    for i, row in pairs(articons.rows) do
        for j, icon in pairs(row) do
            if #self.icon_filter.value == 0 or get_filter_score(icon:lower(), self.icon_filter.value) ~= 0 then
                local image = articons.get(icon)
                local icon_button = self.icon_box:add(
                    rtk.Button{
                        icon=image,
                        color=app:get_articulation_color(self.current_color),
                        tooltip=icon
                    }
                )
                icon_button.onclick = function()
                    self:send_change(self.current_color, icon)
                end
            end
        end
    end
end

function IconPicker:send_change(color, icon)
    if self.on_change ~= nil then
        self.on_change(color, icon)
    end
end

function IconPicker:set_current_color(color)
    self.current_color = color
    self:refresh()
end

return IconPicker