local MainClassName = {
    Objects = {}, -- В этом случае как раз метод мог быть статичным (c#), если бы нужно было показывать только одну подсказку, но так как 
    -- предполагается по очерёдный показ, их нужно хранить.
    Speed = {
        [1] = 0.05,
        [2] = 0.01,
        [3] = 0.05,
    },
    Sizes = {
        X = 1920/2-300/2,
        Y = 200,
        Wi = 300,
        Hi = 100,
    }
}

SetClassToPublic("Notificator:Main", MainClassName) -- не обязательно каждый класс объявлять публичным. Ставить паблик нужно только если 
-- его необходимо использовать в других классах.

MainClassName.create = function(text)
    local object = {}
    object.Element = createElement("Key")
    object.Text = text or " "
    object.AnimType = 1
    object.AnimProgress = 0
    object.AnimSpeed = MainClassName.Speed[object.AnimType]
    table.insert(MainClassName.Objects, object)
    if not isEventHandlerAdded("onClientRender", root, MainClassName.onRender) then
        -- можно использовать как вариант добавления хандлера указанный на сервере, так и этот. Взависимости от того, какая нагрузка допустима
        -- на сервере предпочтительно использовать переменные, дабы не тратить время на выполнение isEventHandlerAdded .
        -- на клиенте - взависимости от ситуации
        addEventHandler("onClientRender", root, MainClassName.onRender) 
    end
    return object.Element 
end

MainClassName.destroy = function(object)
    local id = MainClassName.getIDByObj(object)
    if not id then return false end
    if isElement(MainClassName.Objects[id].Element) then destroyElement(MainClassName.Objects[id].Element) end
    table.remove(MainClassName.Objects, id)
    if #MainClassName.Objects == 0 then
        if isEventHandlerAdded("onClientRender", root, MainClassName.onRender) then
            removeEventHandler("onClientRender", root, MainClassName.onRender)
        end
    end
end

MainClassName.getIDByObj = function(object)
    for i = 1, #MainClassName.Objects do
        if MainClassName.Objects[i].Element == object then
            return i
        end
    end
    return false
end

MainClassName.show = function(text)
    if not text then return end
    MainClassName.create(text)
end

MainClassName.onRender = function()
    local tempObject = MainClassName.Objects[1] -- tempObject не обязателен, мне так удобней в данной ситуации
    if not tempObject then 
        removeEventHandler("onClientRender", root, MainClassName.onRender) 
        return false 
    end
    tempObject.AnimProgress = math.min(tempObject.AnimProgress+tempObject.AnimSpeed, 1)
    if tempObject.AnimProgress == 1 then
        tempObject.AnimType = tempObject.AnimType + 1
        tempObject.AnimSpeed = MainClassName.Speed[tempObject.AnimType]
    end
    local posX,posY = MainClassName.Sizes.X,MainClassName.Sizes.Y
    if tempObject.AnimType == 1 then
        posY = interpolateBetween(-MainClassName.Sizes.Wi,0,0,MainClassName.Sizes.Y,0,0,tempObject.AnimProgress, "InQuad")
    elseif tempObject.AnimType == 2 then
        -- no changes, menu is just staying and waiting
    elseif tempObject.AnimType == 3 then
        posY = interpolateBetween(MainClassName.Sizes.Y,0,0,-MainClassName.Sizes.Wi,0,0,tempObject.AnimProgress, "InQuad")
    else
        MainClassName.destroy(tempObject.Element)
    end
    dxDrawRectangle(posX,posY,MainClassName.Sizes.Wi,MainClassName.Sizes.Hi,tocolor(0,0,0,255))
    dxDrawText(tempObject.Text, posX+MainClassName.Sizes.Wi-dxGetTextWidth(tempObject.Text, 1,"default-bold")/2, posY, 1,1, tocolor(255,255,255,255), 1, "default-bold")
    -- данный показ ЮИ не используется, показано исключительно для примера метода. В идеале нужно разграничивать логику и показ.
end

MainClassName.managerOfEvents = function(funcname, ...)
    -- способ обмена данными между клиентом и сервером, может быть как у каждого класса свой, так и только у центрального, который распределяет
    -- по сабклассам.
	MainClassName[funcname](...)
end
addEvent("Notificator:Main",true)
addEventHandler("Notificator:Main",getRootElement(), MainClassName.managerOfEvents)