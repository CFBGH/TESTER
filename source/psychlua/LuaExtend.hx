package psychlua;

import cpp.vm.Gc;

class LuaExtend {
    public static function implement(funk:FunkinLua) {
        var lua:State = funk.lua;

        Lua_helper.add_callback(lua, "getMemoryUsage", function() {
			return Gc.memUsage();
		});

        
    }
}