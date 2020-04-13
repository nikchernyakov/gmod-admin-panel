netstream.Hook('server-console-message', function(message)
    print(message)
end)

--netstream.Start('client -> server', 123, true, 'string')