package xtable;


public class _DatabaseMetaData_ extends mkdb.util.DatabaseMetaData {
	@Override
	public boolean isVerifyMkdb() {
		return false;
	}
	public void DatabaseMetaData1(){
		// xbeans
		{
			Bean bean = new Bean("ListListenerTestEffect", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "type"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("ListListenerTestEffects", false, false);
			super.addVariableFor(bean
				, "effects"
				, "list", "", "ListListenerTestEffect", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Cacheb0", false, false);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "l"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "marshal"
				, "binary", "", "", ""
				, "", "", "128"
				);
			super.addVariableFor(bean
				, "seti"
				, "set", "", "int", ""
				, "", "", "10"
				);
			super.addVariableFor(bean
				, "cacheb1"
				, "Cacheb1", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Cacheb1", false, false);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "l"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "marshal"
				, "binary", "", "", ""
				, "", "", "128"
				);
			super.addVariableFor(bean
				, "seti"
				, "set", "", "int", ""
				, "", "", "10"
				);
			super.addVariableFor(bean
				, "cacheb2"
				, "Cacheb2", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Cacheb2", false, false);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "l"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "marshal"
				, "binary", "", "", ""
				, "", "", "128"
				);
			super.addVariableFor(bean
				, "seti"
				, "set", "", "int", ""
				, "", "", "10"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("xbeanwithcbean", false, false);
			super.addVariableFor(bean
				, "xc1"
				, "xcompare", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "xc2"
				, "list", "", "xcompare2", ""
				, "", "", "120"
				);
			super.addVariableFor(bean
				, "f"
				, "float", "", "", ""
				, "1", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("First", false, false);
			super.addVariableFor(bean
				, "s"
				, "short", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "l"
				, "long", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "text"
				, "string", "", "", ""
				, "123", "", "32"
				);
			super.addVariableFor(bean
				, "marshal"
				, "binary", "", "", ""
				, "", "", "128"
				);
			super.addVariableFor(bean
				, "sets"
				, "set", "", "string", ""
				, "", "", "200;value:32"
				);
			super.addVariableFor(bean
				, "seti"
				, "set", "", "int", ""
				, "", "", "200"
				);
			super.addVariableFor(bean
				, "setl"
				, "set", "", "long", ""
				, "", "", "200"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Second", false, false);
			super.addVariableFor(bean
				, "setfirst"
				, "set", "", "int", ""
				, "", "", "2"
				);
			super.addVariableFor(bean
				, "listfirst"
				, "list", "", "First", ""
				, "", "", "2"
				);
			super.addVariableFor(bean
				, "vectorfirst"
				, "vector", "", "First", ""
				, "", "", "2"
				);
			super.addVariableFor(bean
				, "mapfirst"
				, "map", "int", "First", ""
				, "", "", "2"
				);
			super.addVariableFor(bean
				, "mapxfirst"
				, "map", "string", "First", ""
				, "", "", "2;key:32"
				);
			super.addVariableFor(bean
				, "first"
				, "First", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "marshal2"
				, "binary", "", "", ""
				, "", "", "128"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("RB", false, false);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "1", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("RBTest", false, false);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "rb"
				, "RB", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "set"
				, "set", "", "RB", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "list"
				, "list", "", "RB", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "map"
				, "map", "int", "RB", ""
				, "", "", "200"
				);
			super.addVariableFor(bean
				, "tree"
				, "treemap", "int", "RB", ""
				, "", "", "200"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Family", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "level"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "contribution"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "leaderid"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "creatorid"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "name"
				, "string", "", "", ""
				, "", "", "32"
				);
			super.addVariableFor(bean
				, "aim"
				, "string", "", "", ""
				, "", "", "32"
				);
			super.addVariableFor(bean
				, "pub"
				, "string", "", "", ""
				, "", "", "32"
				);
			super.addVariableFor(bean
				, "memebers"
				, "map", "int", "MemberInfo", ""
				, "", "", "200"
				);
			super.addVariableFor(bean
				, "status"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "create_time"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "well_known"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("MemberInfo", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "name"
				, "string", "", "", ""
				, "", "", "32"
				);
			super.addVariableFor(bean
				, "offline"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "level"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "menpai"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Any", true, false);
			super.addVariableFor(bean
				, "any"
				, "Object", "", "", ""
				, "", "", "32"
				);
			super.addVariableFor(bean
				, "anyset"
				, "set", "", "Object", ""
				, "", "", "200;value:32"
				);
			super.addVariableFor(bean
				, "bool"
				, "boolean", "", "", ""
				, "false", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Any2", true, false);
			super.addVariableFor(bean
				, "any"
				, "Any", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "anyset"
				, "set", "", "Any", ""
				, "", "", "200"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("AnyFake", false, false);
			super.addVariableFor(bean
				, "fake"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("TestLP", false, false);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "set1"
				, "set", "", "int", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "map1"
				, "map", "int", "int", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "list1"
				, "list", "", "int", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "map2"
				, "map", "int", "RB", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "list2"
				, "list", "", "RB", ""
				, "", "", "100"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Set2", false, false);
			super.addVariableFor(bean
				, "sf"
				, "set", "", "First", ""
				, "", "", "100"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("TestType", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vmap"
				, "map", "int", "Second", ""
				, "", "", "10"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("NetBar", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "barname"
				, "string", "", "", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "level"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("varMap", false, false);
			super.addVariableFor(bean
				, "v"
				, "map", "int", "int", ""
				, "", "", "100"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("varSet", false, false);
			super.addVariableFor(bean
				, "v"
				, "set", "", "int", ""
				, "", "", "100"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("varXBean", false, false);
			super.addVariableFor(bean
				, "vint"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vstring"
				, "string", "", "", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "vset"
				, "set", "", "int", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "vmap"
				, "map", "int", "int", ""
				, "", "", "100"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("SubBean", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("DataType", false, false);
			super.addVariableFor(bean
				, "id"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "max"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "mshort"
				, "short", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "mfloat"
				, "float", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "name"
				, "string", "", "", ""
				, "", "", "32"
				);
			super.addVariableFor(bean
				, "mobject"
				, "binary", "", "", ""
				, "", "", "128"
				);
			super.addVariableFor(bean
				, "sub"
				, "SubBean", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "set"
				, "set", "", "SubBean", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "list"
				, "list", "", "SubBean", ""
				, "", "", "100"
				);
			super.addVariableFor(bean
				, "map"
				, "map", "string", "SubBean", ""
				, "", "", "100;key:32"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("fxbean0", false, false);
			super.addVariableFor(bean
				, "a"
				, "set", "", "boolean", ""
				, "", "fboolean", "100"
				);
			super.addVariableFor(bean
				, "b"
				, "list", "", "fcbean", ""
				, "", "fcbean", "100"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("fxbean", false, false);
			super.addVariableFor(bean
				, "a"
				, "set", "", "boolean", ""
				, "", "fboolean", "20"
				);
			super.addVariableFor(bean
				, "b"
				, "list", "", "fcbean", ""
				, "", "fcbean", "20"
				);
			super.addVariableFor(bean
				, "c"
				, "vector", "", "float", ""
				, "", "ffloat", "100"
				);
			super.addVariableFor(bean
				, "d"
				, "map", "int", "fcbean", ""
				, "", "key:fint;fcbean", "100"
				);
			super.addVariableFor(bean
				, "e"
				, "treemap", "string", "short", ""
				, "", "key:fstring;fshort", "100;key:32"
				);
			super.addVariableFor(bean
				, "f"
				, "fxbean0", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "g"
				, "int", "", "", ""
				, "1", "fint", ""
				);
			super.addVariableFor(bean
				, "h"
				, "binary", "", "", ""
				, "", "warn", "128"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("depends1", false, false);
			super.addVariableFor(bean
				, "dummyavoidwarning"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Flush", false, false);
			super.addVariableFor(bean
				, "countlong"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "busy"
				, "float", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "dummy"
				, "Family", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("SecondaryIndex", false, false);
			super.addVariableFor(bean
				, "secondaryindex"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("Diskdbh", false, false);
			super.addVariableFor(bean
				, "data"
				, "binary", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("yyy", false, false);
			super.addVariableFor(bean
				, "a"
				, "set", "", "int", ""
				, "", "", "4096"
				);
			super.addVariableFor(bean
				, "b"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "c"
				, "string", "", "", ""
				, "", "", "4096"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("xxx", false, false);
			super.addVariableFor(bean
				, "a"
				, "set", "", "int", ""
				, "", "", "4096"
				);
			super.addVariableFor(bean
				, "b"
				, "yyy", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "c"
				, "string", "", "", ""
				, "", "", "4096"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("varValue", false, false);
			super.addVariableFor(bean
				, "vint"
				, "int", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vstring"
				, "string", "", "", ""
				, "i am string", "", "4096"
				);
			super.addVariableFor(bean
				, "vshort"
				, "short", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vbool"
				, "boolean", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vlong"
				, "long", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vbinary"
				, "binary", "", "", ""
				, "", "", "4096"
				);
			super.addVariableFor(bean
				, "vxxx"
				, "xxx", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vyyy"
				, "xxx", "", "", ""
				, "", "", ""
				);
			super.addVariableFor(bean
				, "vmap"
				, "map", "int", "string", ""
				, "", "", "4096;value:1024"
				);
			super.addVariableFor(bean
				, "vset"
				, "set", "", "xxx", ""
				, "", "", "4096"
				);
			super.addVariableFor(bean
				, "vlist"
				, "list", "", "yyy", ""
				, "", "", "4096"
				);
			super.addVariableFor(bean
				, "vvector"
				, "vector", "", "short", ""
				, "", "", "4096"
				);
			super.addBean(bean);
		}
		// cbeans
		{
			Bean bean = new Bean("xcompare", false, true);
			super.addVariableFor(bean
				, "b"
				, "boolean", "", "", ""
				, "true", "", ""
				);
			super.addVariableFor(bean
				, "s"
				, "short", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "i"
				, "int", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "l"
				, "long", "", "", ""
				, "1", "", ""
				);
			super.addVariableFor(bean
				, "text"
				, "string", "", "", ""
				, "123", "", "32"
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("xcompare2", false, true);
			super.addVariableFor(bean
				, "xc1"
				, "xcompare", "", "", ""
				, "", "", ""
				);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("fcbean", false, true);
			super.addBean(bean);
		}
		{
			Bean bean = new Bean("depends2", false, true);
			super.addBean(bean);
		}
		// tables
		super.addTable("t4", "DB", "string", false, "First", "", "key:32");
		super.addTable("table_int", "DB", "int", false, "int", "", "");
		super.addTable("testmerge", "DB", "long", true, "RBTest", "", "");
		super.addTable("fcbean", "DB", "fcbean", false, "int", "", "");
		super.addTable("memory", "MEMORY", "int", false, "int", "", "");
		super.addTable("cachenull", "MEMORY", "int", false, "Family", "", "");
		super.addTable("fshort", "DB", "short", false, "int", "", "");
		super.addTable("listlistenertest", "MEMORY", "long", false, "ListListenerTestEffects", "", "");
		super.addTable("keyisxcompare2", "DB", "xcompare2", false, "xbeanwithcbean", "", "");
		super.addTable("anyfake", "DB", "int", false, "AnyFake", "", "");
		super.addTable("f1", "DB", "int", false, "fcbean", "key:fint;value:fcbean", "");
		super.addTable("f2", "DB", "string", false, "fxbean", "key:fstring", "key:32");
		super.addTable("f3", "DB", "string", false, "fxbean", "key:f2", "key:32");
		super.addTable("tany", "MEMORY", "int", false, "Any", "", "");
		super.addTable("second", "MEMORY", "int", false, "Second", "", "");
		super.addTable("table_set", "DB", "int", false, "varSet", "", "");
		super.addTable("diskdbh", "DB", "long", false, "Diskdbh", "", "");
		super.addTable("fboolean", "DB", "boolean", false, "int", "", "");
		super.addTable("mem", "MEMORY", "int", false, "DataType", "", "");
		super.addTable("table_map", "DB", "int", false, "varMap", "", "");
		super.addTable("table_xbean", "DB", "int", false, "varXBean", "", "");
		super.addTable("table_int_int", "DB", "int", false, "int", "", "");
		super.addTable("flush3", "DB", "int", false, "Flush", "", "");
		super.addTable("flush2", "DB", "int", false, "Flush", "", "");
		super.addTable("secondaryindex", "DB", "long", false, "SecondaryIndex", "", "");
		super.addTable("flush1", "DB", "int", false, "Flush", "", "");
		super.addTable("cachetest", "DB", "long", false, "RBTest", "", "");
		super.addTable("table_string", "DB", "int", false, "string", "", "value:32");
		super.addTable("at2", "DB", "long", true, "int", "", "");
		super.addTable("tlong", "MEMORY", "int", false, "long", "", "");
		super.addTable("fint", "DB", "int", false, "int", "", "");
		super.addTable("fstring", "DB", "string", false, "int", "", "key:32");
		super.addTable("ffloat", "DB", "float", false, "int", "", "");
		super.addTable("var_test_s", "DB", "string", false, "varValue", "", "key:32");
		super.addTable("netbar", "DB", "long", true, "NetBar", "", "");
		super.addTable("t4cache", "DB", "long", false, "Cacheb0", "", "");
		super.addTable("any", "MEMORY", "int", false, "Any", "", "");
		super.addTable("var_test_m", "MEMORY", "long", false, "varValue", "", "");
		super.addTable("flong", "DB", "long", false, "int", "", "");
		super.addTable("testtype", "DB", "long", true, "TestType", "", "");
		super.addTable("afirst", "DB", "long", true, "First", "", "");
		super.addTable("family", "DB", "long", true, "Family", "", "");
		super.addTable("lperform", "DB", "long", true, "TestLP", "", "");
		super.addTable("first", "DB", "long", false, "First", "", "");
		super.addTable("t2", "DB", "long", false, "int", "", "");
		super.addTable("t3", "DB", "int", false, "string", "", "value:32");
		super.addTable("tshort", "MEMORY", "int", false, "short", "", "");
	}
	public _DatabaseMetaData_() {
		DatabaseMetaData1();
	}
}

