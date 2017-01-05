local Poker = class("Poker",function()
	return cc.Sprite:create()
end)

function Poker.create(point, suit, scale)
    local poker = Poker.new(point, suit, scale)
	return poker
end
--[[
1.方块
2.梅花
3.红桃
4.黑桃
]]
function Poker:ctor(point, suit, scale) --1的点数传进来的时候为14
    self:setScale(scale)
    if point == 14 then
    	point = 1
    end
    if point == 0 then
    self:addChild(cc.Sprite:createWithSpriteFrameName("poker_back.png"))
        return
    end
    local bottom = cc.Sprite:createWithSpriteFrameName("poker_bg.png")
    self:addChild(bottom)
    
    local left = cc.Sprite:createWithSpriteFrameName(string.format("poker_suit_%d.png", suit-1))
    self:addChild(left)
    
    local rightUp
    if suit == 1 or suit == 3 then
    rightUp = cc.Sprite:createWithSpriteFrameName(string.format("poker_point_red_%d.png", point))
    else
    rightUp = cc.Sprite:createWithSpriteFrameName(string.format("poker_point_black_%d.png", point))
    end
    self:addChild(rightUp)
    
    local rightDown
    if point < 11 then
    rightDown = cc.Sprite:createWithSpriteFrameName(string.format("poker_suit_pic_%d.png", suit-1))
    else
        if suit == 1 or suit == 3 then
        rightDown = cc.Sprite:createWithSpriteFrameName(string.format("poker_suit_pic_red_%d.png", point))
        else    
        rightDown = cc.Sprite:createWithSpriteFrameName(string.format("poker_suit_pic_black_%d.png", point))
        end
    end
    self:addChild(rightDown)
    
end

return Poker