
package xbean;

public interface ImpExamStatePassRole extends mkdb.Bean {
	public ImpExamStatePassRole copy(); // 深拷贝
	public ImpExamStatePassRole toData(); // 一个 Data 实例
	public ImpExamStatePassRole toBean(); // 一个 Bean 实例
	public ImpExamStatePassRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ImpExamStatePassRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public int getAccrightnum(); // 累积答对次数(vill-prov-state)
	public long getStateexamtime(); // 通过stateexam所用的时间

	public void setRoleid(long _v_); // 
	public void setAccrightnum(int _v_); // 累积答对次数(vill-prov-state)
	public void setStateexamtime(long _v_); // 通过stateexam所用的时间
}
