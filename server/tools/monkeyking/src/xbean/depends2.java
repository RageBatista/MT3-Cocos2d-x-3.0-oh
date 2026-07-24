
package xbean;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class depends2 implements Marshal, Comparable<depends2> {


	public depends2() {
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		return _os_;
	}

	@Override
	public int compareTo(depends2 _o_) {
		if (_o_ == this)
			return 0;
		int _c_ = 0;
		return _c_;
	}

	@Override
	public boolean equals(Object _o_) {
		if (_o_ instanceof depends2)
			return 0 == this.compareTo((depends2)_o_);
		return false;
	}

	@Override
	public int hashCode() {
		int _h_ = 0;
		return _h_;
	}

}
