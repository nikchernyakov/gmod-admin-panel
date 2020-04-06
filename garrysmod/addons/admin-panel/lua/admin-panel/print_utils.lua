INFO = "Info"
ERROR = "Error"
DENIED = "Denied"

function AdpPrint(status, message)
    print(" [ADMIN-PANEL]: "..status.. " - "..tostring(message))
end