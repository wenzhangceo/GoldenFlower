local Algorithm = {}

local PokerType = {
	{"BaoZi", 10},
	{"ShunJin", 8},
	{"JinHua", 6},
	{"ShunZi", 4},
	{"DuiZi", 2},
	{"SanPai", 1},
	{"TeShu", 1}
}
--1的点数为14

-- 1.点数 2.花色
local function pokerSort(pA, pB)
	if pA[1] < pB[1] then
		return true
	elseif pA[1] > pB[1] then
		return false
	else
		if pA[2] < pB[2] then
			return true
		else
			return false
		end
	end
end

function Algorithm.getPokerType(pokers)

		assert(#pokers==3, "pokers count is not 3!")
		table.sort(pokers,pokerSort)

		--豹子
		if pokers[1][1] == pokers[3][1] then
			return PokerType[1], pokers[1]
		end

		--顺金
		if pokers[1][2] == pokers[2][2] and pokers[2][2] == pokers[3][2] then
			if pokers[1][1]+1 == pokers[2][1] and pokers[2][1]+1 == pokers[3][1] then
				return PokerType[2], pokers[3]
			end
			-- 1,2,3
			if pokers[1][1] ==2 and pokers[2][1] == 3 and pokers[3][3] == 14 then
				return PokerType[2], pokers[2]
			end
		end

		--金花
		if pokers[1][2] == pokers[2][2] and pokers[2][2] == pokers[3][2] then
			return PokerType[3], pokers[3]
		end

		--顺子
		if pokers[1][1]+1 == pokers[2][1] and pokers[2][1]+1 == pokers[3][1] then
			return PokerType[4], pokers[3]
		end
		-- 1,2,3
		if pokers[1][1] ==2 and pokers[2][1] == 3 and pokers[3][3] == 14 then
			return PokerType[4], pokers[2]
		end

		--对子
		if pokers[1][1] == pokers[2][1] or pokers[2][1] == pokers[3][1] then
			return PokerType[5], pokers[2] --未考虑花色
		end

		--特殊
		if pokers[1][1] == 2 and pokers[2][1] == 3 and pokers[3][1] == 5 then
			return PokerType[7], pokers[3]
		end

		--散牌
		return PokerType[6], pokers[3]
end

function Algorithm.printPokerType(type, keyPoker)
	print("牌型为："..type[1].." ".."关键牌点数:"..keyPoker[1].." ".."关键牌花色:"..keyPoker[2])
end

function Algorithm.printPokers(pokers)
	local s = ""
	for i=1,3 do
		s = s.."点数:"..pokers[i][1]..",".."花色:"..pokers[i][2].." " --Lua中的字符串不能+
	end
	print("原始牌:"..s)
end

function Algorithm.comparePoker(typeA, keyPokerA, typeB, keyPokerB)  --A和B比较，A的牌大则返回赢得的倍数
	--处理特殊情况
	if typeA[1] == "BaoZi" and typeB[1] == "TeShu" then
		return -typeB[2]
	end

	if typeB[1] == "BaoZi" and typeA[1] == "TeShu" then
		return typeA[2]
	end

	if typeA[2] > typeB[2] then
		return typeA[2]
	elseif typeA[2] < typeB[2] then
		return -typeB[2]
	else
		if keyPokerA[1] > keyPokerB[1] then
			return typeA[2]
		elseif keyPokerA[1] < keyPokerB[1] then
			return -typeB[2]
		else
			if keyPokerA[2] > keyPokerB[2] then
				return typeA[2]
			elseif keyPokerA[2] < keyPokerB[2] then
				return -typeB[2]
			else
				return 0
			end
		end
	end
end

return Algorithm
