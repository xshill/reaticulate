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
local BankDetails = require 'editor.bankdetails'
local ArticulationList = require 'editor.articulationlist'
local ArticulationDetails = require 'editor.articulationdetails'

local screen = {
    minw = 200,
    widget = nil,
    articulations = {
    },
    group = '',
    name = '',
    message = '',
    articulations = {}
}

function screen.init()
    screen.main_box = rtk.HBox{lpadding=20, rpadding=20, spacing=20}
    screen.widget = rtk.Viewport{screen.main_box}
    screen.bank_details = BankDetails()
    screen.articulation_list = ArticulationList()
    screen.articulation_details = ArticulationDetails()
    app.parent:resize(1600, 700)
    screen.main_box:add(screen.bank_details.widget, {fillw=true, fillh=true})
    screen.main_box:add(screen.articulation_list.widget, {fillw=true, fillh=true})
    screen.main_box:add(screen.articulation_details.widget, {fillw=true, fillh=true})

    screen.articulation_list.on_change = function(art)
        screen.articulation_details:set_articulation(art)
    end
    screen.articulation_details.on_change = function()
        screen.articulation_list:refresh()
    end

    screen.articulation_list:set_list(screen.articulations)
    screen.bank_details:set_articulations(screen.articulations)

    screen.bank_details.on_load = function(articulations)
        screen.articulations = articulations
        screen.articulation_list:set_list(articulations)
        screen.bank_details:set_articulations(articulations)
    end
end

return screen
