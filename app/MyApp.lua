cc.exports.MyApp = {}

function MyApp:run()
    local MainScene = require("app.views.MainScene") --返回table
    local scene = MainScene.create() --返回userdata
    --特别注意require(module)返回的是一个table,创建场景需要的类型是userdata
    if scene ~= nil then
        cc.Director:getInstance():runWithScene(scene)
    end
end

return MyApp

--[[
C++绑定到lua的基本原理:首先创建一个userdata来存放c++对象的指针,然后给userdata添加元表,用index元方法映射c++类中的对象方法.
]]