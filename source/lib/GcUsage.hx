package lib;

import haxe.macro.Expr;
import haxe.macro.Context;
class GcUsage{
	macro public static function gatherFrom(expr : Expr) : Expr{
		var pos = Context.currentPos();
		if(!Context.defined("cpp") || !Context.defined("HXCPP_TELEMETRY") || !Context.defined("HXCPP_STACK_TRACE")){
			Context.error("only cpp target with '-D HXCPP_TELEMETRY' and '-D HXCPP_STACK_TRACE' supported",pos);
			return null;
		}
		
		var newExpr = macro {
		var __gcUsage = @:privateAccess new GcUsage();
		@:privateAccess __gcUsage.begin();
	};

	newExpr = append(newExpr,expr);
	newExpr = append(newExpr,macro {
		@:privateAccess __gcUsage.end();
		__gcUsage;
	});
	
	
	return newExpr;
	}
	
	static function append(expr : Expr, exprToAdd : Expr) : Expr{
		return
		switch(expr.expr){
			case EBlock(exprs):
				exprs.push(exprToAdd);
				expr;
			default :
				expr.expr = EBlock([{pos:expr.pos,expr:expr.expr}, exprToAdd]);
				expr;
		}
	}
	
	#if !macro
	public var numAllocations(default,null) : Int = -1;
	public var numReallocations(default,null) : Int = -1;
	public var numDeallocations(default,null) : Int = -1;
	public var bytesUsed(get,never) : Int;
	public var bytesReserved(get,never) : Int;
	
	var threadNum : Int = -1;
	var bytesUsedBefore : Int = 0;
	var bytesUsedAfter : Int = 0;
	var bytesReservedBefore : Int = 0;
	var bytesReservedAfter : Int = 0;
	
	private function new(){
	}
	
	function get_bytesUsed() : Int{
		return bytesUsedAfter - bytesUsedBefore;
	}
	
	function get_bytesReserved() : Int{
		return bytesReservedAfter - bytesReservedBefore;
	}
	
	private function begin(){
		cpp.vm.Gc.run(true);
		threadNum = untyped  __global__.__hxcpp_hxt_start_telemetry(true, true);
		untyped  __global__.__hxcpp_hxt_ignore_allocs(1);
		cpp.vm.Gc.run(true);
		bytesReservedBefore = untyped __global__.__hxcpp_gc_reserved_bytes();
		bytesUsedBefore = untyped __global__.__hxcpp_gc_used_bytes();
		untyped  __global__.__hxcpp_hxt_ignore_allocs(-1);
	}
	
	private function end(){
		cpp.vm.Gc.run(true);
		bytesReservedAfter = untyped __global__.__hxcpp_gc_reserved_bytes();
		bytesUsedAfter = untyped __global__.__hxcpp_gc_used_bytes();
		untyped  __global__.__hxcpp_hxt_ignore_allocs(1);
		untyped  __global__.__hxcpp_hxt_stash_telemetry();
		gatherData();
	}
	
	@:functionCode('
		TelemetryFrame* frame = __hxcpp_hxt_dump_telemetry(threadNum);
		numAllocations = -1;
		numDeallocations = -1;
		numReallocations = -1;
		if (frame->allocation_data!=0){
			int size = frame->allocation_data->size();
			int i = 0;
			numAllocations = 0;
			numReallocations = 0;
			numDeallocations = 0;
			while (i<size) {
				if (frame->allocation_data->at(i)==0) {
					i+=5;
					numAllocations++;
				}
				else if (frame->allocation_data->at(i)==1) { 
					i+=2; 
					numDeallocations ++; 
				}
				else if (frame->allocation_data->at(i)==2) {
					i+=4; 
					numReallocations ++; 
				}
			}
			return null();
		}
		
		')
	function gatherData(){
		
	}

	
	#end
}


