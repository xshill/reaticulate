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
local OutputList = require 'editor.outputlist'
local IconPicker = require 'editor.iconpicker'

local ArticulationDetails = rtk.class('ArticulationDetails')


function ArticulationDetails:initialize()
    self.widget = rtk.VBox{spacing=10}
    self.widget:add(rtk.Heading{'Articulation Details'})
    self.articulation = nil
    self.output_list = OutputList()
    self.icon_picker = IconPicker()

    self.details_box = self.widget:add(rtk.VBox{spacing=10})
    self.widget:add(self.output_list.widget)
    self.on_change = nil

    self:refresh()
end

function ArticulationDetails:refresh()
    self.details_box:remove_all()
    if self.articulation == nil then
        return
    end

    local icon_entry = self:add_field(self.details_box, 'Icon', function()
        local color = self.articulation.color or reabank.colors.default
        local padding = 2
        local darkicon = false
        if not color:startswith('#') then
            color = app:get_articulation_color(color)
        end
        if rtk.color.luma(color) > rtk.light_luma_threshold then
            darkicon = true
        end
        self.articulation.icon = articons.get(self.articulation.iconname, darkicon, 'note-eighth')

        return rtk.Button{
            label='',
            icon=self.articulation.icon,
            color=color,
            padding=padding,
            w=self.articulation.icon.w + 2 * padding,
            h=self.articulation.icon.h + 2 * padding,
        }
    end)
    local name_entry = self:add_field(self.details_box, 'Name', function()
        return rtk.Entry{value=self.articulation.name}
    end)
    local program_entry = self:add_field(self.details_box, 'Program', function()
        return rtk.Entry{value=self.articulation.program}
    end)
    local test_button = self.details_box:add(rtk.Button{
        label='Test',
        color='#2d5f99'
    })


    icon_entry.onclick = function()
        self.icon_picker:set_current_color(self.articulation.color)
        self.icon_picker.on_change = function(color, icon)
            self.articulation.color = color

            if icon ~= nil then
                self.articulation.iconname = icon
            end

            self:refresh()
            if self.on_change ~= nil then
                self.on_change()
            end
        end
        self.icon_picker.popup:attr('anchor', icon_entry.parent)
        self.icon_picker.popup:open()
    end
    name_entry.onchange = function()
        self.articulation.name = name_entry.value

        if self.on_change ~= nil then
            self.on_change()
        end
    end
    program_entry.onchange = function()
        self.articulation.program = program_entry.value

        if self.on_change ~= nil then
            self.on_change()
        end
    end
end

function ArticulationDetails:set_articulation(articulation)
    self.articulation = articulation
    self:refresh()

    if articulation == nil then
        self.output_list:set_list(nil)
    else
        self.output_list:set_list(articulation._outputs)
    end
end

function ArticulationDetails:add_field(box, name, entry_factory)
    local box = box:add(rtk.HBox{spacing=10})
    local label = box:add(rtk.Text{name .. ':'}, {minw=75, valign='center'})

    local entry
    if entry_factory == nil then
        entry = box:add(rtk.Entry(), {valign='center', fillw=true})
    else
        entry = box:add(entry_factory(), {valign='center', fillw=true})
    end

    return entry
end

return ArticulationDetails
