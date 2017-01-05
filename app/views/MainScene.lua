require("app.views.GameConfig")
local MainScene = class("MainScene", function()
    return cc.Scene:create()
end)

local checkBoxes = {}
local selectBtnIndex = 1
local touchBetRectIndex = 1
local coinsSpriteName = {"golden_flower_black_chip.png",
    "golden_flower_blue_chip.png",
    "golden_flower_green_chip.png",
    "golden_flower_purple_chip.png",
    "golden_flower_red_chip.png"
}

local countDownTime = WaittingBetTime

local schedule, betSchedule

local backPokers = {}

local pokers = {}

local selfBetGold = {0, 0, 0, 0}

local resultGold = {}

local Poker = require("app.views.Poker")
local Algorithm = require("app.views.Algorithm")
local timesBottom = {} --牌型倍数底框
local timesLabel = {} --牌型倍数
local pokerTypeSprite = {} --牌型
local pokerTypeResult = {{},{},{},{},{}} --牌型+关键值
local betCoins = {{},{},{},{}}
local pokersSprite = {}
local canBet = true

local testPokers = require("app.views.testPokers")
local testIndex = 1
function MainScene:ctor()
    --加载游戏资源
    --注意C++的接口为:addSpriteFramesWithFile lua的接口为:addSpriteFrames
    cc.SpriteFrameCache:getInstance():addSpriteFrames("poker.plist", "poker.png")
    self.rootNode = cc.CSLoader:createNode("GameScene.csb")
    self:addChild(self.rootNode)
    self.chatBtn = self.rootNode:getChildByName("Button_chat")
    self.chatBtn:setPressedActionEnabled(true)
    self.BetCountDownLabel = self.rootNode:getChildByName("AtlasLabel_betCountDown")
    self.beginBet = self.rootNode:getChildByName("golden_flower_begin")
    
    for i=1,5 do
        local btnLabel = self.rootNode:getChildByName(string.format("AtlasLabel_%d", i))
        btnLabel:setString(tostring(ButtonCount[i]))
        if string.len(btnLabel:getString()) > 4 then
            btnLabel:setScale(0.9*4.0/string.len(btnLabel:getString()))
        else
            btnLabel:setScale(0.9)
        end
    end
    
    self.allBetCountLable = {}
    self.selfBetCountLable = {}
    self.noBetWords = {}
    self.betEffect = {}
    
    for i=1,4 do
    --注意最后一个参数
        self.selfBetCountLable[i] = cc.LabelAtlas:_create("0","golden_flower_font_bet_number.png",16,27,string.byte("0"))
        self.selfBetCountLable[i]:setPosition(190+300*(i-1), 545)
        self.selfBetCountLable[i]:setAnchorPoint(0.5, 0.5)
        self:addChild(self.selfBetCountLable[i])
        
        self.allBetCountLable[i] = cc.LabelAtlas:_create("0","golden_flower_font_bet_number.png",16,27,string.byte("0"))
        self.allBetCountLable[i]:setPosition(190+300*(i-1), 338)
        self.allBetCountLable[i]:setAnchorPoint(0.5, 0.5)
        self:addChild(self.allBetCountLable[i])

        self.noBetWords[i] = self.rootNode:getChildByName(string.format("golden_flower_no_bet_%d",i))
        self.betEffect[i] = self.rootNode:getChildByName(string.format("golden_flower_effect_%d",i))      
    end

    for i=1,5 do
    	timesBottom[i] = self.rootNode:getChildByName(string.format("golden_flower_times_bottom_%d",i))
        timesLabel[i] = self.rootNode:getChildByName(string.format("golden_flower_times_label_%d",i))
        pokerTypeSprite[i] = self.rootNode:getChildByName(string.format("golden_flower_times_type_%d",i)) 
    end
    
    local function btnCallBack(pSender, type)
        if type == ccui.TouchEventType.ended then
            if pSender == self.chatBtn then
                print("chatBtn")
            end
        end
    end
    self.chatBtn:addTouchEventListener(btnCallBack)
    
    --[[
    button事件:btnCallBack(pSender, type)
    ccui.TouchEventType.began
    ccui.TouchEventType.moved
    ccui.TouchEventType.ended
    ccui.TouchEventType.canceled
    ]]
    local betRect = {}
    for i=1, 4 do
    	betRect[i] = cc.rect(99+298*(i-1), 358, 187, 170)
    end
    
    local function getRandomPosition(index)
        math.randomseed(os.time()+os.clock())  --增加随机性
        return cc.p(math.random(betRect[index].x+59/2,betRect[index].x+betRect[index].width-59/2),math.random(betRect[index].y+59/2,betRect[index].y+betRect[index].height-59/2))
    end
    
    local function touchBegan(touch, event)
    	if canBet == false then
    		return false
    	end
        print("touchBegan")
        for i = 1,4 do
            if cc.rectContainsPoint(betRect[i], touch:getLocation()) then
                touchBetRectIndex = i
                if self:updatePlayerGold(-ButtonCount[selectBtnIndex]) then
                	selfBetGold[touchBetRectIndex] = selfBetGold[touchBetRectIndex] + ButtonCount[selectBtnIndex]
                    local coins = cc.Sprite:create(coinsSpriteName[selectBtnIndex])
                    coins:setPosition(88, 89)      
                    coins:runAction(cc.MoveTo:create(0.5,getRandomPosition(i)))
                    self.rootNode:addChild(coins)
                    table.insert(betCoins[touchBetRectIndex],coins)
            	end                
            	break
            end
        end
        return false
    end
    
    local function touchMoved(touch, event)
    end
    
    local function touchEnded(touch, event)
    end
    
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self)
  
    local function betBtnCallBack(pSender, type) --利用CheckBox来实现RadioButton
        if type == ccui.CheckBoxEventType.selected then
            for i =1,#checkBoxes do
                print(checkBoxes[i]:isSelected())
                if pSender == checkBoxes[i] then
                    pSender:setSelected(true)
                    selectBtnIndex = i
                else
                    checkBoxes[i]:setSelected(false)
                end
            end
            --添加逻辑处理
        else
            if pSender == checkBoxes[i] then
                pSender:setSelected(true)
                selectBtnIndex = i
            end
            --添加逻辑处理
        end
    end
    
    for i =1,5 do
       checkBoxes[i] = self.rootNode:getChildByName(string.format("CheckBox_%d", i))
       checkBoxes[i]:addEventListener(betBtnCallBack)
    end
    
    --押注定时器
    local function bettingSchedule(dt)
        if countDownTime == -1 then
            self.BetCountDownLabel:setVisible(false)
            schedule:unscheduleScriptEntry(betSchedule)
            countDownTime = WaittingBetTime
            --注意lua中的接口为cc.EventCustom:new与c++中的不同
            canBet = false
            local disposeCardEvent = cc.EventCustom:new("disposeCard")
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(disposeCardEvent)
        else
            if countDownTime == WaittingBetTime then
               self.beginBet:setVisible(false)
        	   self.BetCountDownLabel:setVisible(true)
            end
            self.BetCountDownLabel:setString(tostring(countDownTime))
            countDownTime = countDownTime -1
        end
    end
    
    schedule = cc.Director:getInstance():getScheduler()
    betSchedule =  schedule:scheduleScriptFunc(bettingSchedule, 1, false)

local function getPokerTypeSpriteName(index) --返回牌型精灵
	if pokerTypeResult[index][1][2] >= 4 then
		return string.format("golden_flower_times_type_%d.png", pokerTypeResult[index][1][2]), string.format("golden_flower_%d_times.png", pokerTypeResult[index][1][2])
	end
	if pokerTypeResult[index][1][1] == "TeShu" then
		return "golden_flower_spencial.png", "golden_flower_times_word.png"
	end
	if pokerTypeResult[index][1][1] == "DuiZi" then
		if pokerTypeResult[index][2][1] == 14 then 
			return "golden_flower_pair_1.png", "golden_flower_times_word.png"
		end
		return string.format("golden_flower_pair_%d.png",pokerTypeResult[index][2][1]), "golden_flower_2_times.png"
	end
	if pokerTypeResult[index][1][1] == "SanPai" then
		if pokerTypeResult[index][2][1] == 14 then 
			return "golden_flower_1big.png", "golden_flower_times_word.png"
		end
		return string.format("golden_flower_%dbig.png",pokerTypeResult[index][2][1]), "golden_flower_times_word.png"
	end
end

    
     --显示牌型
    local function showPokerType(index)
    	local p1, p2 = getPokerTypeSpriteName(index)
    	timesBottom[index]:setVisible(true)
    	pokerTypeSprite[index]:setVisible(true)
        pokerTypeSprite[index]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(p1))
    	timesLabel[index]:setVisible(true)  
        timesLabel[index]:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(p2))
    end  

    --显示每个位置输赢结算
    local function showGoldResult()
    	for i=1,4 do
    		if selfBetGold[i] == 0 then
    			self.noBetWords[i]:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(1),cc.Hide:create()))
    			resultGold[i] = 0
    		else
    			resultGold[i] = selfBetGold[i]*Algorithm.comparePoker(pokerTypeResult[i][1], pokerTypeResult[i][2],pokerTypeResult[5][1], pokerTypeResult[5][2])
    			local winGoldLabel
    			if resultGold[i] > 0 then
    				self.betEffect[i]:setVisible(true)
    				local animation = cc.Animation:create()
    				for i=0,4 do
    					animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("golden_flower_effect_%d.png",i)))
    				end
    				animation:setDelayPerUnit(0.15)
    				animation:setRestoreOriginalFrame(true)
    				local action = cc.Animate:create(animation)
    				self.betEffect[i]:runAction(cc.RepeatForever:create(action))
    				local function stopEffectCallBack()
    					self.betEffect[i]:stopAllActions()
    					self.betEffect[i]:setVisible(false)
    				end
    				local stopFunc = cc.CallFunc:create(stopEffectCallBack)
    				self.betEffect[i]:runAction(cc.Sequence:create(cc.DelayTime:create(2),stopFunc))
    				winGoldLabel = cc.LabelAtlas:_create("0","golden_flower_win_num.png",65,85,string.byte("0")-1)
    			else
    				winGoldLabel = cc.LabelAtlas:_create("0","golden_flower_lost_num.png",65,85,string.byte("0")-1)
    			end
                winGoldLabel:setPosition(self.noBetWords[i]:getPosition())
        		winGoldLabel:setAnchorPoint(0.5, 0.5)
        		winGoldLabel:setScale(0.5)
        		winGoldLabel:setString(string.format("%c%d",string.byte("0")-1,math.abs(resultGold[i])))
       			self.rootNode:addChild(winGoldLabel)
       			winGoldLabel:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
       			local endPos
       			if resultGold[i] > 0 then
       				endPos = cc.p(88, 89)
       			else
       				endPos = cc.p(472, 646)
       			end
       			for k=1,#betCoins[i] do
       				betCoins[i][k]:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.MoveTo:create(0.5,endPos),cc.RemoveSelf:create()))
       			end
    		end
    	end
    end
    
    local function showGameResult()
    	local GameResult = require("app.views.GameResult")
    	local winGold = 0
    	for i=1,4 do
    		winGold = winGold + resultGold[i]
    	end
    	local resultData = {{},{},{},{},{}}
    	for i=1,5 do
    		resultData[i][1] = pokerTypeResult[i][1][1]
    		if i == 5 then
    			resultData[i][2] = -winGold
    		else
    			resultData[i][2] = resultGold[i]
    		end
    	end
    	local gameResult = GameResult.create(winGold, resultData)
    	self:addChild(gameResult)
    end

    --清理画面
    local function cleanGameScene()
    	for i=1,5 do
    		timesLabel[i]:setVisible(false)
    		timesBottom[i]:setVisible(false)
    		pokerTypeSprite[i]:setVisible(false)
    	end
    	for i=1,#pokersSprite do
    		pokersSprite[i]:removeFromParent()
    	end
    	for i=1,4 do
    		self.allBetCountLable[i]:setString("0")
    		self.selfBetCountLable[i]:setString("0")
    		self.noBetWords[i]:setVisible(false)
    		selfBetGold[i] = 0
    		for j = #betCoins[i],1,-1 do
    			table.remove(betCoins[i], j)
    		end
    	end
    	for i = #backPokers,1,-1 do
    		if backPokers[i] ~= nil then
    			table.remove(backPokers, i)
    		end
    	end
    	for i = #pokersSprite,1,-1 do
    		if pokersSprite[i] ~= nil then
    			table.remove(pokersSprite, i)
    		end
    	end
    	for i = #pokers,1,-1 do
    		if pokers[i] ~= nil then
    			table.remove(pokers, i)
    		end
    	end
    end
    --翻牌回调
    local function showCardCallBack()
        print("Begin show card.")
        for i =1,5 do
            for j=1,3 do
                local poker = Poker.create(pokers[(i-1)*3+j][1],pokers[(i-1)*3+j][2],0.25)
                backPokers[(i-1)*3+j]:setVisible(false)
                if i ~= 5 then
                	poker:setPosition(cc.p(124+68*(j-1)+298*(i-1),274))
                else
                	poker:setScale(0.21)
                	poker:setPosition(cc.p(768+58*(j-1), 665))
                end
                self.rootNode:addChild(poker)
                table.insert(pokersSprite, poker)
                backPokers[(i-1)*3+j]:removeFromParent()
                showPokerType(i)
            end
        end
        --显示结算
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(showGoldResult),cc.DelayTime:create(3.75),cc.CallFunc:create(showGameResult),cc.CallFunc:create(cleanGameScene)))
    end
      
    --发牌事件
    local function disposeCardCallBack()
    	print("Begin dispose card.")
    	for i =1,5 do
    	   for j =1,3 do
                local backPoker = Poker.create(0,1,0.25)
                backPoker:setPosition(1075,673)
                self.rootNode:addChild(backPoker)
                --backPokers[i][j] = backPoker
                table.insert(backPokers,backPoker)
                if i ~= 5 then
                backPoker:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(i-1)*4+0.1*(j-1)*3),cc.MoveTo:create(0.25, cc.p(124+68*(j-1)+298*(i-1),274))))
                else
                backPoker:setScale(0.21)
                backPoker:runAction(cc.MoveTo:create(0.25, cc.p(768+58*(j-1), 665)))
                end
    	   end
    	end
    	
    	--随机产生牌
        math.randomseed(os.time())
    	for i =1,5 do
    	   for j=1,3 do
                --pokers[i][j] = {math.random(2,14),math.random(1,4)}
                if TestPokers == true then
                	assert(#testPokers ~= 0, "Please check GameConfig, testPokers size is 0")  
                	if testIndex > #testPokers then
                		testIndex = 1
                	end
                	table.insert(pokers,testPokers[testIndex][(i-1)*3+j])
                	testIndex = testIndex + 1
                else
                	table.insert(pokers,{math.random(2,14),math.random(1,4)})
                end
    	   end
    	   pokerTypeResult[i][1], pokerTypeResult[i][2] = Algorithm.getPokerType({pokers[(i-1)*3+1], pokers[(i-1)*3+2], pokers[(i-1)*3+3]})
    	end
    	
    	local showCardFunc = cc.CallFunc:create(showCardCallBack)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*12+0.5), showCardFunc)) --不要忘记写create
    end
    
    
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local disposeCardListener = cc.EventListenerCustom:create("disposeCard", disposeCardCallBack)
    dispatcher:addEventListenerWithSceneGraphPriority(disposeCardListener,self)

    local function gameRestartCallBack()
    	self.beginBet:setVisible(true)
    	canBet = true
    	betSchedule =  schedule:scheduleScriptFunc(bettingSchedule, 1, false)
    end

    local gameRestartListener = cc.EventListenerCustom:create("gameRestart",gameRestartCallBack)
    dispatcher:addEventListenerWithSceneGraphPriority(gameRestartListener,self)
end

function MainScene:updatePlayerGold(gold)
    local currentGold = tonumber(self.rootNode:getChildByName("Text_player_gold"):getString())
    if currentGold > 0 then
        if currentGold+gold >= 0 then
            self:updateSelfBetGold(-gold)
            self.rootNode:getChildByName("Text_player_gold"):setString(tostring(currentGold+gold))
        else
            self:updateSelfBetGold(currentGold)
            self.rootNode:getChildByName("Text_player_gold"):setString("0")
        end
        return true
    else
        print("Player's gold is less than 0!")
        return false
    end           
end

function MainScene:updateSelfBetGold(gold)
    local currentAllBetGold = tonumber(self.allBetCountLable[touchBetRectIndex]:getString())
    self.allBetCountLable[touchBetRectIndex]:setString(tostring(currentAllBetGold+gold))
    local currentSelfBetGold = tonumber(self.selfBetCountLable[touchBetRectIndex]:getString())
    self.selfBetCountLable[touchBetRectIndex]:setString(tostring(currentSelfBetGold+gold))
end

return MainScene
