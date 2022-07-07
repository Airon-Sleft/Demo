local MainClassName = {
    Objects = {}, -- хранит экземпляры класса. Этой таблицы может не быть, если класс подразумевает ТОЛЬКО ОДИН объект. Называю: Таблица экземпляров.
    isEventLogged = false,
    issomeFunc = true -- означает что функция someFunc может быть вызывана с клиента 
}

-- Важные принципы: 
-- 1. Don't repeat youself (по возможности, допустимы исключения, если так получится в итоге лучше)
-- 2. Названия переменных, описывающие хранимые её данные, названия функции, описывающие её действия.
-- 3. Приоритет в читаемость и масштабируемость кода. Оптимизация ОЧЕНЬ важная, но необходимо удерживать баланс с читаемостью и удобством.
-- 4. Деление на мелкие классы. В файле не должно быть много кода ( до 500 строчек, с исключениями, само собой), для этого, например:
--     разделять методы на отдельные файлы классов: NotitficatorGet (методы, которые только возвращают какие то данные, при этом класс.
--     будет статичным (c#), то есть не иметь возможность создать экземпляр, только обработка данных). 
-- 5. Один метод - одна задача. Думаю пояснять что это не нужно, само собой с исключениями там, где считаешь это нужным.
-- 6. Айрон - туповатый кодер, если он что-то делает неправильно, ему нужно об этом сказать.
-- ... принципе в процессе написания.

SetClassToPublic("Notificator:Main", MainClassName)

MainClassName.create = function(typeNotificator, text, tableOfSomeValue)
    -- Условный Конструктор
    local object = {}
    object.Element = createElement("Key") -- элемент для поиска нужной таблицы с данными. Лучше не создавать отдельный, а использовать те, что под
    -- рукой, и будут актуально на протяжении всей жизни Объекта (как экземпляра класса). Если такого объекта нет, создаём как в примере.
    -- Если тут есть предложения по лучше - предлагай. Выбрал его за то, что он точно не изменится (таблица может быть скопирована, например в таймере)
    -- и всегда уникальный.
    object.Text = text or " " -- желательно исключать возможности ошибок из за некорректных входных параметров, либо возвращать ошибку при создании объекта
    object.TypeNotificator = typeNotificator or 1
    object.TableOfValues = tableOfSomeValue -- можно отправлять и таблицами, если аргументов получается очень много, опять же, лучше перебирать каждый
    -- из них, для исключения ошибок.
    if object.TypeNotificator == 1 then
        if not MainClassName.isEventLogged then
            addEventHandler("onLogged", getRootElement(), MainClassName.onLogged)
            MainClassName.isEventLogged = true
        end
    end
    table.insert(MainClassName.Objects, object)
    return object.Element -- возвращаем экземпляр объекта, которому сможем обращаться к методам класса
    -- использую именно добавление в таблицу по последовательным индексам, чтобы иметь быстрый способ перебора элементов (ipairs, instead of pairs)
    -- в отдельных случаях, можно использовать Элемент в качестве индекса таблицы Экземпляров.
    -- возвращать индекс понятное дело нельзя, так как он собьётся после удаления Экземпляра.
end

MainClassName.destroy = function(object)
    -- это условный Деструктор, соответственно, всё дерьмо, которое должно происходить при удалении Экземпляра, должно происходить здесь, либо вызываться отсюда
    -- функция может быть привязана к удалению элемента (onElementDestroy), чтобы объект можно было удалять через destroyElement, но это не обязательно
    local id = MainClassName.getIDByObj(object)
    if not id then return false end
    if isElement(MainClassName.Objects[id].Element) then destroyElement(MainClassName.Objects[id].Element) end -- избегаем ошибки из-за несуществующего элемента
    if #MainClassName.Objects == 0 then
        if MainClassName.isEventLogged then
            removeEventHandler("onLogged", getRootElement(), MainClassName.onLogged)
            MainClassName.isEventLogged = false
        end
    end
end

MainClassName.getIDByObj = function(object)
    -- вообще стандартный метод, встречается почти во всех скриптах, без необходимости менять его особо и не стоит.
    -- переодически необходим поиск ИД по другому элементу, для этого создаётся аналогичный метод,например: getIDByShape
    for i = 1, #MainClassName.Objects do
        if MainClassName.Objects[i].Element == object then
            return i
        end
    end
    return false
end

MainClassName.onLogged = function(player)
    local Getter = GetClass("Notificator:Get")
    for i = 1, #MainClassName.Objects do -- вот это не лучший пример, для таких ситуаций нужно создать отдельную таблицу, которая хранит 
    -- список тех Экземпляров, которые сработывают во время логина. 
        if MainClassName.Objects[i].TypeNotificator == 1 then
            if Getter.isPlayerForNotif(player, MainClassName.Objects[i].TableOfValues.Team) then
                MainClassName.showNotif(player, MainClassName.Objects[i].Text)
            end
        end
    end
    -- возвращать здесь ничего не нужно, ибо некуда.
end
addEvent("onLogged") -- без вызова с клиента, в данном случае

MainClassName.showNotif = function(player, text)
    triggerClientEvent(player, "Notificator:Main", player, "show", text)
    return true
end

MainClassName.managerOfEvents = function(funcname, ...)
    -- способ обмена данными между клиентом и сервером, может быть как у каждого класса свой, так и только у центрального, который распределяет
    -- по сабклассам. Первый параметр всегда клиент, вызывавший событие, соответственно и использовать нужно именно его (если нужен клиент),
    -- во избежании подмены
    -- фукнции которые могут быть вызваны с клиента всегда первым аргументов имееют игрока и прописываются в таблицу класса "is"..funcname
    if not MainClassName["is"..funcname] then iprint("Not allowed call func (MainNameClass) ", funcname) return end
	MainClassName[funcname](client or source, ...)
end
addEvent("Notificator:Main",true)
addEventHandler("Notificator:Main",getRootElement(), MainClassName.managerOfEvents)