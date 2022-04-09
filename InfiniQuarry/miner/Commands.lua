Command = {}
function Command:new(name, execute, wait)
    new_cmd = {}
    new_cmd.name = name
    new_cmd.execute = execute
    new_cmd.wait = wait
    setmetatable(new_cmd, self)
    self.__index = self
    return new_cmd
end

commands = {}
table.insert(commands, Command:new("UPDATE_HOME_POS", function(args) miner.homePos = args end, false))
table.insert(commands, Command:new("START", function() actions.startup() end, true))
table.insert(commands, Command:new("STOP", function() miner.working = false end, false))
table.insert(commands, Command:new("HOME", function() actions.home() end, true))
table.insert(commands, Command:new("SHUTDOWN", function() os.shutdown() end, true))
table.insert(commands, Command:new("RESTART", function() os.reboot() end, true))
table.insert(commands, Command:new("RESET_SIZE", function() quarry_position_mgr.size = 3 quarry_position_mgr.pos = 0 quarry_position_mgr.side = 0 quarry_position_mgr.worksitePos = {} end, false))
table.insert(commands, Command:new("PLACE_CHKLD", function() actions.chunkloader(true) end, true))
table.insert(commands, Command:new("MINE_CHKLD", function() actions.chunkloader(false) end, true))
table.insert(commands, Command:new("SET_HELPER", function(args) miner.helper = args end, false))