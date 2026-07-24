
package xbean;

public interface RoleFuShiRecord extends mkdb.Bean {
	public RoleFuShiRecord copy(); // 深拷贝
	public RoleFuShiRecord toData(); // 一个 Data 实例
	public RoleFuShiRecord toBean(); // 一个 Bean 实例
	public RoleFuShiRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleFuShiRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.FuShiRecord> getRecords(); // 
	public java.util.List<xbean.FuShiRecord> getRecordsAsData(); // 

}
