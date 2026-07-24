
package xbean;

public interface CreateNpcExecType extends mkdb.Bean {
	public CreateNpcExecType copy(); // 深拷贝
	public CreateNpcExecType toData(); // 一个 Data 实例
	public CreateNpcExecType toBean(); // 一个 Bean 实例
	public CreateNpcExecType toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CreateNpcExecType toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public fire.msp.GMCreateNpcExec getExecinstance(); // 

	public void setExecinstance(fire.msp.GMCreateNpcExec _v_); // 
}
