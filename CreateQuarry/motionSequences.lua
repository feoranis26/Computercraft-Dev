sequences = {
    movePositiveX = {
        {
            action = "activate", off = coords.posXCarriageReturnPiston
        },
        {
            action = "checkPowercell", off = coords.posXPowercell
        },
        {
            action = "activate", off = coords.posXCarriagePiston
        },
        {
            action = "gotoY", off = 6
        },
        {
            action = "delay", delay = 8
        },
        {
            action = "deactivate", off = coords.posXCarriagePiston
        },
        {
            action = "add_to_pos", change = {x = 16, y = 0, z = 0}
        },
        {
            action = "delay", delay = 2
        },
        {
            action = "deactivate", off = coords.posXCarriageReturnPiston
        },
        {
            action = "gotoY", off = 6
        },
    },

    moveNegativeX = {
        {
            action = "activate", off = coords.negXCarriageReturnPiston, block = "create:gearshift"
        },
        {
            action = "checkPowercell", off = coords.negXPowercell
        },
        {
            action = "activate", off = coords.negXCarriagePiston, block = "create:gearshift"
        },
        {
            action = "gotoY", off = 6
        },
        {
            action = "delay", delay = 8
        },
        {
            action = "deactivate", off = coords.negXCarriagePiston
        },
        {
            action = "add_to_pos", change = {x = -16, y = 0, z = 0}
        },
        {
            action = "delay", delay = 2
        },
        {
            action = "deactivate", off = coords.negXCarriageReturnPiston
        },
        {
            action = "gotoY", off = 6
        }
    },

    moveNegativeZ = {
        {
            action = "activate", off = coords.negZCarriageReturnPiston, block = "create:gearshift"
        },
        {
            action = "checkPowercell", off = coords.negZPowercell
        },
        {
            action = "activate", off = coords.negZCarriagePiston, block = "create:gearshift"
        },
        {
            action = "gotoY", off = 6
        },
        {
            action = "delay", delay = 8
        },
        {
            action = "deactivate", off = coords.negZCarriagePiston
        },
        {
            action = "add_to_pos", change = {x = 0, y = 0, z = -16}
        },
        {
            action = "delay", delay = 2
        },
        {
            action = "deactivate", off = coords.negZCarriageReturnPiston
        },
        {
            action = "gotoY", off = 6
        }
    },

    movePositiveZ = {
        {
            action = "activate", off = coords.posZCarriageReturnPiston
        },
        {
            action = "checkPowercell", off = coords.posZPowercell
        },
        {
            action = "activate", off = coords.posZCarriagePiston
        },
        {
            action = "gotoY", off = 6
        },
        {
            action = "delay", delay = 8
        },
        {
            action = "deactivate", off = coords.posZCarriagePiston
        },
        {
            action = "add_to_pos", change = {x = 0, y = 0, z = 16}
        },
        {
            action = "delay", delay = 2
        },
        {
            action = "deactivate", off = coords.posZCarriageReturnPiston
        },
        {
            action = "gotoY", off = 6
        },
    },
    dig = {
        {
            action = "activate", off = coords.drillPlatformSwitch
        },
        {
            action = "wait_for_block", off = coords.drillPoleInspectLoc
        },
        {
            action = "deactivate", off = coords.drillPlatformSwitch
        },
        {
            action = "wait_for_block", off = coords.drillPoleInspectLoc
        },
    }
}