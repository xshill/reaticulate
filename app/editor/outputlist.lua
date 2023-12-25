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

local OutputList = rtk.class('OutputList')

function default_output()
    return {type='note', value='C0'}
end

function OutputList:initialize()
    self.widget = rtk.VBox{spacing=10}
    self.widget:add(
        rtk.Heading{'Outputs'},
        {tpadding=10}
    )
    self.output_list = rtk.VBox{spacing=10}
    self.viewport = self.widget:add(rtk.Viewport{self.output_list})
    self.outputs = nil
    self.selected_output = nil
    self.drag_group = DragGroup('outputs', self.output_list, self.outputs, nil)

    self:refresh()
end

function OutputList:set_list(outputs)
    self.outputs = outputs
    self.drag_group.model = outputs
    self:refresh()
end

function OutputList:refresh()
    self.output_list:remove_all()

    if self.outputs == nil then
        return
    end

    for n, output in ipairs(self.outputs) do
        local box = self.output_list:add(rtk.HBox{padding={5, 5, 5, 5}, spacing=10})

        local drag_handle = rtk.ImageBox{
            image=rtk.Image.make_icon('drag_vertical:large'),
            cursor=rtk.mouse.cursors.REAPER_HAND_SCROLL,
            halign='center',
            valign='center',
            show_scrollbar_on_drag=true,
            tooltip='Click-drag to reorder articulation'
        }
        box:add(drag_handle, {valign='center'})
        self.drag_group:register(drag_handle, box)

        local output_choices = {'program', 'cc', 'note', 'note-hold', 'pitch', 'art'}
        local output_menu = rtk.OptionMenu{
            flat=true,
            menu=output_choices,
            selected=table.find(output_choices, output.type),
        }
        output_menu.onchange = function(_, item)
            output.type = item.label
        end
        box:add(output_menu, {valign='center'})

        local value_entry = rtk.Entry{value=output.value}
        value_entry.onchange = function(self)
           output.value = self.value
        end
        box:add(value_entry, {valign='center', fillw=true})

        local delete_button = box:add(
            rtk.Button{
                icon='delete',
                color='#9f2222',
                tooltip='Remove Output',
            },
            {valign='center'}
        )
        delete_button.onclick = function()
            table.remove(self.outputs, n)
            self:refresh()
        end
    end

    local add_button = self.output_list:add(
        rtk.Button{
            icon='add_circle_outline', label='Add',
            truncate=false,
            color='#208160',
            cursor=rtk.mouse.cursors.HAND,
        },
        {tpadding=10, halign='left', fillw=true}
    )
    add_button.onclick = function()
        table.insert(self.outputs, default_output())
        self:refresh()
    end
end

return OutputList
