
package xbean;

public interface ImpeachMent extends mkdb.Bean {
	public ImpeachMent copy(); // 深拷贝
	public ImpeachMent toData(); // 一个 Data 实例
	public ImpeachMent toBean(); // 一个 Bean 实例
	public ImpeachMent toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ImpeachMent toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getImpeachroleid(); // 发起弹劾的人
	public long getImpeachtime(); // 发起弹劾的时间
	public short getImpeachallnum(); // 需要相应弹劾的总人数
	public java.util.List<Long> getAcceptimpeachroleids(); // 相应弹劾的角色ID
	public java.util.List<Long> getAcceptimpeachroleidsAsData(); // 相应弹劾的角色ID

	public void setImpeachroleid(long _v_); // 发起弹劾的人
	public void setImpeachtime(long _v_); // 发起弹劾的时间
	public void setImpeachallnum(short _v_); // 需要相应弹劾的总人数
}
