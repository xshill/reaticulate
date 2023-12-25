local rtk = require 'rtk'

--------------------------------------------------------------
-- DragGroup class
-- 
-- A helper class that implements the core logic of re-ordering vbox items using drag handles.
--------------------------------------------------------------
local DragGroup = rtk.class('DragGroup')

function DragGroup:initialize(group_name, list_box, model, spacer)
    self.group_name = group_name
    self.list_box = list_box
    self.model = model
    self.spacer = spacer

    if spacer then
        spacer.ondropfocus = function(target, event, handle, src_box)
            self:move_box(src_box, nil, nil)
            return true
        end
    end
end

function DragGroup:register(handle, box)
    -- Used by ondropmousemove() to ensure the widget being dragged is a Reaticulate box and
    -- not something incompatible (like e.g. the resize handle for undocked windows).
    -- Also ensures that both src and target belong to the same group when reordering.
    handle.drag_group = self.group_name

    handle.onmouseenter = function() return true end
    local previous_bg = nil

    handle.ondragstart = function(event)
        previous_bg = box.bg
        box:attr('bg', '#5b7fac30')
        box:attr('tborder', {'#497ab7', 2})
        box:attr('bborder', box.tborder)
        return box
    end
    handle.ondragend = function(event)
        box:attr('bg', previous_bg)
        box:attr('tborder', {'#00000000', 0})
        box:attr('bborder', box.tborder)
    end

    box.ondropfocus = function(self, event, _, src_box)
        return true
    end
    box.ondropmousemove = function(target, event, handle, src_box)
        if target ~= src_box and handle.drag_group == self.group_name then
            local rely = event.y - target.clienty - target.calc.h / 2
            if rely < 0 then
                self:move_box(src_box, box, -1)
            else
                self:move_box(src_box, box, 1)
            end
        end
    end
end

function DragGroup:move_box(src, target, position)
    if not rtk.isa(src, rtk.Box) or src == target then
        -- Nothing to move.
        return false
    end

    local srcidx = self.list_box:get_child_index(src)

    if target then
        local targetidx = self.list_box:get_child_index(target)

        if srcidx > targetidx and position < 0 then
            if self.model then
                local articulation = table.remove(self.model, srcidx)
                table.insert(self.model, targetidx, articulation)
            end

            self.list_box:reorder_before(src, target)
        elseif targetidx > srcidx and position > 0 then
            if self.model then
                local articulation = table.remove(self.model, srcidx)
                table.insert(self.model, targetidx, articulation)
            end

            self.list_box:reorder_after(src, target)
        end
    else
        if self.model then
            local articulation = table.remove(self.model, srcidx)
            table.insert(self.model, articulation)
        end

        self.list_box:reorder(src, #self.list_box.children + 1)
    end
    return true
end

return DragGroup