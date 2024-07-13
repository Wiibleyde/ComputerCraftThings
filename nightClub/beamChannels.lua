local channels = {
    channel = "GLOBAL",
    children = {
        {
            channel = "DL",
            children = {
                { channel = "DL1" },
                { channel = "DL2" },
                { channel = "DL3" },
                { channel = "DL4" },
            },
        },
        {
            channel = "DR",
            children = {
                { channel = "DR1" },
                { channel = "DR2" },
                { channel = "DR3" },
                { channel = "DR4" },
            },
        },
        {
            channel = "U",
            children = {
                { channel = "U1" },
                { channel = "U2" },
                { channel = "U3" },
                { channel = "U4" },
                { channel = "U5" },
                { channel = "U6" },
            },
        },
    },
}

local fxChannels = {
    channel = "GLOBALFX",
    enable = false,
    children = {
        {
            channel = "SMOKE1",
            enable = false,
        }
    }
}
