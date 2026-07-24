
package xbean;

public interface RoleTradingHisRecordList extends mkdb.Bean {
	public RoleTradingHisRecordList copy(); // 深拷贝
	public RoleTradingHisRecordList toData(); // 一个 Data 实例
	public RoleTradingHisRecordList toBean(); // 一个 Bean 实例
	public RoleTradingHisRecordList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleTradingHisRecordList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.RoleTradingHisRecord> getRoletradinghisrecordlist(); // 
	public java.util.List<xbean.RoleTradingHisRecord> getRoletradinghisrecordlistAsData(); // 

}
