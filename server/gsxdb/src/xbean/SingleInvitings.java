
package xbean;

public interface SingleInvitings extends mkdb.Bean {
	public SingleInvitings copy(); // 深拷贝
	public SingleInvitings toData(); // 一个 Data 实例
	public SingleInvitings toBean(); // 一个 Bean 实例
	public SingleInvitings toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SingleInvitings toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Long> getInvitingids(); // 
	public java.util.Map<Long, Long> getInvitingidsAsData(); // 

}
