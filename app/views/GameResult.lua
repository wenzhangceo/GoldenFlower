local GameResult = class("GameResult", function()
	return cc.Layer:create()
end)

function GameResult.create(winGold, resultData)
	return GameResult.new(winGold, resultData)
end

function GameResult:ctor(winGold, resultData)
	local rootNode = cc.CSLoader:createNode("ResultLayer.csb")
	self:addChild(rootNode)
	local resultType = rootNode:getChildByName("golden_flower_result_type")
	local spriteFramaName, winGoldLabel
	if winGold < 0 then
		spriteFramaName = "golden_flower_lost_word.png"
		winGoldLabel = cc.LabelAtlas:_create("0","golden_flower_lost_num.png",65,85,string.byte("0")-1)
	elseif winGold > 0 then
		spriteFramaName = "golden_flower_win_words.png"
		winGoldLabel = cc.LabelAtlas:_create("0","golden_flower_win_num.png",65,85,string.byte("0")-1)
	else
		spriteFramaName = "golden_flower_sause.png"
		winGoldLabel = cc.LabelAtlas:_create("0","golden_flower_lost_num.png",65,85,string.byte("0")-1)
	end
	resultType:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFramaName))
	winGoldLabel:setPosition(640, 410)
    winGoldLabel:setAnchorPoint(0.5, 0.5)
    winGoldLabel:setString(string.format("%c%d",string.byte("0")-1,math.abs(winGold)))
    rootNode:addChild(winGoldLabel)

    local function getPokerTypeName(type)
    	if type == "PaoZi" then
    		return "豹子"
    	elseif type == "ShunJin" then
    		return "顺金"
    	elseif type == "JinHua" then
    		return "金花"
    	elseif type == "ShunZi" then
    		return "顺子"
        elseif type == "DuiZi" then
    		return "对子"
    	elseif type == "SanPai" then
    		return "散牌"
    	else
    		return "特殊"
    	end

    end
    for i=1,5 do
    	local pokerTypeText = rootNode:getChildByName(string.format("Text_%d",i))
    	pokerTypeText:setString(getPokerTypeName(resultData[i][1]))
    	local resultGoldLabel = cc.LabelAtlas:_create("0","goldenflower_final_result_num.png",20,27,string.byte("0")-2)
    	resultGoldLabel:setPosition(pokerTypeText:getPositionX()+100, pokerTypeText:getPositionY())
    	resultGoldLabel:setAnchorPoint(0.5, 0.5)
    	if resultData[i][2] > 0 then
    		resultGoldLabel:setString(string.format("%c%d",string.byte("0")-2,math.abs(resultData[i][2])))
    	else
    		resultGoldLabel:setString(string.format("%c%d",string.byte("0")-1,math.abs(resultData[i][2])))
    	end
    	rootNode:addChild(resultGoldLabel)
    end

    local scheduler,countDownScheduler  -- 定时器是全局的，不会随着结点释放，应手动停止

    local function continueCallBack(pSender, type)
    	if type == ccui.TouchEventType.ended then
    		self:removeFromParent()
    		scheduler:unscheduleScriptEntry(countDownScheduler)
                        --发送游戏重新开始事件
            local disposeCardEvent = cc.EventCustom:new("gameRestart")
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(disposeCardEvent)
    	end
    end
    local continueBtn = rootNode:getChildByName("Button_continue")
    continueBtn:addTouchEventListener(continueCallBack)

    local conutDownTimeLabel = rootNode:getChildByName("AtlasLabel_time")


    local function countDownUpdate(dt)
    	local time = tonumber(conutDownTimeLabel:getString())
    	if time == 0 then
    		continueCallBack(continueBtn, ccui.TouchEventType.ended)
    	else
    		conutDownTimeLabel:setString(tostring(time-1))
    	end
    end
    scheduler = cc.Director:getInstance():getScheduler()
    countDownScheduler = scheduler:scheduleScriptFunc(countDownUpdate, 1, false)
end
return GameResult