
package xbean;

public interface Flush extends mkdb.Bean {
	public Flush copy(); // deep clone
	public Flush toData(); // a Data instance
	public Flush toBean(); // a Bean instance
	public Flush toDataIf(); // a Data instance If need. else return this
	public Flush toBeanIf(); // a Bean instance If need. else return this

	public long getCountlong(); // 
	public float getBusy(); // 
	public xbean.Family getDummy(); // 

	public void setCountlong(long _v_); // 
	public void setBusy(float _v_); // 
}
