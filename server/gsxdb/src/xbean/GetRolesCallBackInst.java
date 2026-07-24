
package xbean;

public interface GetRolesCallBackInst extends mkdb.Bean {
	public GetRolesCallBackInst copy(); // 深拷贝
	public GetRolesCallBackInst toData(); // 一个 Data 实例
	public GetRolesCallBackInst toBean(); // 一个 Bean 实例
	public GetRolesCallBackInst toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public GetRolesCallBackInst toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public fire.msp.IGetRolesCallBack getCallback(); // 

	public void setCallback(fire.msp.IGetRolesCallBack _v_); // 
}
