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

local BankDetails = rtk.class('BankDetails')

function BankDetails:initialize()
    self.widget = rtk.VBox{spacing=10}
    self.articulations = {}

    self.bank_menu = self.widget:add(rtk.OptionMenu{menu={}}, {fillw=true})
    self.bank_menu.onchange = function()
        local guid = self.bank_menu.selected_id
        local bank = reabank.get_bank_by_guid(guid)
        local articulations = {}
        for i, art in ipairs(bank.articulations) do
            local outputs = {}
            for j, out in ipairs(art:get_outputs()) do
                local args = out.args
                if out.type == 'note' or out.type == 'note-hold' then
                    args = {}
                    for k, v in ipairs(out.args) do
                        if k == 1 then
                            table.insert(args, note_to_name(v))
                        else
                            table.insert(args, v)
                        end
                    end
                end
                local new_output = {
                    type=out.type,
                    value=table.concat(args, ',')
                }
                table.insert(outputs, new_output)
            end

            local new_articulation = reabank.Articulation({guid=nil}, art.program, art.name, {
                _outputs = outputs,
                color = art.color,
                iconname = art.iconname
            })
            table.insert(articulations, new_articulation)
        end
        
        if self.on_load then
            self.on_load(articulations)
        end
    end

    self.widget:add(rtk.Heading{'Bank Settings'})
    local details_box = self.widget:add(rtk.VBox{spacing=10})
    local group_entry = self:add_field(details_box, 'Group')
    local name_entry = self:add_field(details_box, 'Name')
    local short_name_entry = self:add_field(details_box, 'Short Name')
    local message_entry = self:add_field(details_box, 'Message')
    self.inherit_menu = self:add_field(details_box, 'Inherit', function()
        return rtk.OptionMenu{menu=banklist_menu_spec}
    end)

    self.widget:add(
        rtk.Heading{'Default Articulation Behavior'},
        {tpadding=10}
    )
    local art_behavior_box = self.widget:add(rtk.VBox{spacing=10})
    local chase_flag_cb = art_behavior_box:add(rtk.CheckBox{'Chase CCs on channel change', value=true})
    local antihang_cb = art_behavior_box:add(rtk.CheckBox{'Prevent note hanging', value=true})
    local antihangcc_cb = art_behavior_box:add(rtk.CheckBox{'Prevent note hanging from sudden or breath CCs', value=true})
    local nobank_cb = art_behavior_box:add(rtk.CheckBox{'Block bank select messages', value=true})
    local flag_checkboxes = {
        chase = chase_flag_cb,
        antihang = antihang_cb,
        antihangcc = antihangcc_cb,
        nobank = nobank_cb
    }

    self.widget:add(
        rtk.Heading{'Bank Behavior'},
        {tpadding=10}
    )
    local bank_behavior_box = self.widget:add(rtk.VBox{spacing=10})
    local chase_ccs_entry = self:add_field(bank_behavior_box, 'Chase CCs')
    local default_program_entry = self:add_field(bank_behavior_box, 'Default Program')

    local bank_action_box = self.widget:add(rtk.HBox{spacing=10}, {halign='right'})
    local save_button = bank_action_box:add(rtk.Button{label='Save Bank', color='#208160'}, {halign='right'})
    save_button.onclick = function()
        local flags = {}
        for flag, cb in pairs(flag_checkboxes) do
            -- Don't explicitly set flags if they're at the default value
            -- (they all default to true)
            if cb.value == false then
                flags[flag] = false
            end
        end
        local bank = reabank.Bank(nil, nil, name_entry.value, {}, false)
        bank.group = group_entry.value
        bank.shortname = short_name_entry.value
        bank.message = message_entry.value
        bank.chase = chase_ccs_entry.value
        bank.off = default_program_entry.value
        bank.flags = flags
        bank:ensure_guid()

        for i, art in ipairs(self.articulations) do
            bank:add_articulation(art)
        end

        local bank_string = reabank.write_to_string(bank)
        reaper.ShowConsoleMsg(bank_string)
        reabank.import_banks_from_string(bank_string)

        reabank.parseall()
        self:reset_bank_menus()
        self.bank_menu:select(bank.guid, false)
    end

    self:reset_bank_menus()
end

function BankDetails:set_articulations(articulations)
    self.articulations = articulations
end

function BankDetails:reset_bank_menus()
    local banklist_menu_spec = reabank.to_menu()
    self.bank_menu:attr('menu', banklist_menu_spec)
    self.inherit_menu:attr('menu', banklist_menu_spec)
end

function BankDetails:add_field(box, name, entry_factory)
    local box = box:add(rtk.HBox{spacing=10})
    local label = box:add(rtk.Text{name .. ':'}, {minw=125, valign='center'})

    local entry
    if entry_factory == nil then
        entry = box:add(rtk.Entry(), {valign='center', fillw=true})
    else
        entry = box:add(entry_factory(), {valign='center', fillw=true})
    end

    return entry
end

return BankDetails
