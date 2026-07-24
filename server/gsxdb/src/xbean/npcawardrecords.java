
package xbean;

public interface npcawardrecords extends mkdb.Bean {
	public npcawardrecords copy(); // 深拷贝
	public npcawardrecords toData(); // 一个 Data 实例
	public npcawardrecords toBean(); // 一个 Bean 实例
	public npcawardrecords toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public npcawardrecords toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.npcaward> getRecords(); // 
	public java.util.Map<Integer, xbean.npcaward> getRecordsAsData(); // 

}
