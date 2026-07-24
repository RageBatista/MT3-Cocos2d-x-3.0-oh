
package xbean;

public interface xbeanwithcbean extends mkdb.Bean {
	public xbeanwithcbean copy(); // deep clone
	public xbeanwithcbean toData(); // a Data instance
	public xbeanwithcbean toBean(); // a Bean instance
	public xbeanwithcbean toDataIf(); // a Data instance If need. else return this
	public xbeanwithcbean toBeanIf(); // a Bean instance If need. else return this

	public xbean.xcompare getXc1(); // xcompare test
	public java.util.List<xbean.xcompare2> getXc2(); // xcompare2 test
	public java.util.List<xbean.xcompare2> getXc2AsData(); // xcompare2 test
	public float getF(); // float test

	public void setXc1(xbean.xcompare _v_); // xcompare test
	public void setF(float _v_); // float test
}
