INFO = "Info"
ERROR = "Error"
DENIED = "Denied"

adp.print = {}
adp.print.TITLE = " [ADMIN-PANEL]: "

function adp.Print(ply, console, message, status)
    if ply then
        adp.print.ClientPrint(ply, console, message, status)
    else
        adp.print.ServerPrint(message, status)
    end
end

function adp.print.ServerPrint(message, status)
    print(adp.print.GetMessage(message, status))
end

function adp.print.ClientPrint(ply, console, message, status)
    if console then
        netstream.Start(ply, 'server-console-message', adp.print.GetMessage(message, status))
    else
        ply:ChatPrint(adp.print.GetMessage(message, status))
    end
end

function adp.print.GetMessage(message, status)
    if status then
        return adp.print.TITLE..status.." - "..tostring(message)
    else
        return adp.print.TITLE..tostring(message)
    end
end