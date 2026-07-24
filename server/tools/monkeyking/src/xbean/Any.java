
package xbean;

public interface Any extends mkdb.Bean {
	public Any copy(); // deep clone
	public Any toData(); // a Data instance
	public Any toBean(); // a Bean instance
	public Any toDataIf(); // a Data instance If need. else return this
	public Any toBeanIf(); // a Bean instance If need. else return this

	public Object getAny(); // comment
	public java.util.Set<Object> getAnyset(); // comment
	public boolean getBool(); // boolean

	public void setAny(Object _v_); // comment
	public void setBool(boolean _v_); // boolean
}
