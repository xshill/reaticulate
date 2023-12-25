-- Copyright 2017-2022 Jason Tackaberry
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local rtk = require 'rtk'
local feedback = require 'feedback'
local articons = require 'articons'
local reabank = require 'reabank'
local rfx = require 'rfx'
local metadata = require 'metadata'
local log = rtk.log
local debug = require 'lib.debug'
local DragGroup = require 'ux.draggroup'

local ArticulationList = rtk.class('ArticulationList')

function default_articulation()
    return reabank.Articulation({guid=nil}, 1, 'New Articulation', {
        _outputs = {},
        color = 'long',
        iconname = 'note-whole'
    })
end

function ArticulationList:initialize()
    self.widget = rtk.VBox{spacing=10}
    self.widget:add(
        rtk.Heading{'Articulations'},
        {tpadding=10}
    )
    self.art_list = rtk.VBox{spacing=10}
    self.viewport = self.widget:add(rtk.Viewport{self.art_list})
    self.articulations = {}
    self.selected_articulation = nil
    self.drag_group = DragGroup('articulations', self.art_list, self.articulations, nil)
    self.on_change = nil

    self:refresh()
end

function ArticulationList:set_list(articulations)
    self.articulations = articulations
    self.drag_group.model = articulations
    self.selected_articulation = nil

    if self.on_change ~= nil then
        self.on_change(nil)
    end

    self:refresh()
end

function ArticulationList:refresh()
    self.art_list:remove_all()
    for n, art in ipairs(self.articulations) do
        local artbox = self.art_list:add(rtk.HBox{padding={5, 5, 5, 5}, spacing=10})

        local drag_handle = rtk.ImageBox{
            image=rtk.Image.make_icon('drag_vertical:large'),
            cursor=rtk.mouse.cursors.REAPER_HAND_SCROLL,
            halign='center',
            valign='center',
            show_scrollbar_on_drag=true,
            tooltip='Click-drag to reorder articulation'
        }
        artbox:add(drag_handle, {valign='center'})
        self.drag_group:register(drag_handle, artbox)

        local color = art.color or reabank.colors.default
        local padding = 2
        local darkicon = false
        if not color:startswith('#') then
            color = app:get_articulation_color(color)
        end
        if rtk.color.luma(color) > rtk.light_luma_threshold then
            darkicon = true
        end
        art.icon = articons.get(art.iconname, darkicon, 'note-eighth')

        local icon_button = rtk.Button{
            label='',
            icon=art.icon,
            color=color,
            padding=padding,
            w=art.icon.w + 2 * padding,
            h=art.icon.h + 2 * padding,
        }
        artbox:add(icon_button, {valign='center'})

        local name_entry = rtk.Text{art.name}
        name_entry.onchange = function(self)
           art.name = self.value
        end
        artbox:add(name_entry, {valign='center', fillw=true})

        local delete_articulation_button = artbox:add(
            rtk.Button{
                icon='delete',
                color='#9f2222',
                tooltip='Remove Articulation',
            },
            {valign='center'}
        )
        delete_articulation_button.onclick = function()
            local articulation = table.remove(self.articulations, n)
            if self.selected_articulation == articulation then
                self.selected_articulation = nil

                if self.on_change ~= nil then
                    self.on_change(self.selected_articulation)
                end
            end
            self:refresh()
        end

        if self.selected_articulation == art then
            artbox:attr('bg', '#4474e1c0')
        end

        artbox.onclick = function()
            self.selected_articulation = art

            if self.on_change ~= nil then
                self.on_change(self.selected_articulation)
            end
            self:refresh()
        end

        local function on_mouse_enter()
            if self.selected_articulation ~= art then
                artbox:attr('bg', '#4474e180')
            end
        end

        local function on_mouse_leave()
            if self.selected_articulation ~= art then
                artbox:attr('bg', nil)
            end
        end

        artbox.onmouseenter = on_mouse_enter
        artbox.onmouseleave = on_mouse_leave
    end

    local add_button = self.art_list:add(
        rtk.Button{
            icon='add_circle_outline', label='Add',
            truncate=false,
            color='#208160',
            cursor=rtk.mouse.cursors.HAND,
        },
        {tpadding=10, halign='left', fillw=true}
    )
    add_button.onclick = function()
        table.insert(self.articulations, default_articulation())
        self:refresh()
    end
end

return ArticulationList
