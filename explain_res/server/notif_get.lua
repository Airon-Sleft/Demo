local MainGet = {

}

SetClassToPublic("Notificator:Get", MainGet)

MainGet.isPlayerForNotif = function(player, notifAllowed)
    if getElementData(player, "NotificType") == notifAllowed then
        return true
    end
    return false
end