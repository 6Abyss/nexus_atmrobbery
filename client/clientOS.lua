function Notification(text, notType)
        lib.notify({
        title = locale('menutitle'),
        description = text,
        type = notType
    })
end

function StartJobHack()
    return exports['hg_hacking']:Thermite(6, math.random(6,8), 10000, 2, 1, 3000)
end

function StartATMHack()
    return exports['hg_hacking']:Thermite(6, math.random(6,8), 10000, 2, 1, 3000)
end