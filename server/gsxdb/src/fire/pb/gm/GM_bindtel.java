package fire.pb.gm;

import fire.pb.tel.utils.TelBindUtils;

/**
 * 是否开启手机绑定验证
 * @作者阳涛
 * @dateTime 2016年8月18日 下午1:46:48
 * @版本1.0
 */
public class GM_bindtel extends GMCommand {

	@Override
	boolean exec(String[] args) {
		if (args.length < 1) {
			sendToGM("参数格式错误：" + usage());
		}
		final int state = Integer.parseInt(args[0]);
		if (state == 0) {
			TelBindUtils.isOpenBindTelValidate = false;
		} else {
			TelBindUtils.isOpenBindTelValidate = true;
		}
		return true;
	}

	@Override
	String usage() {
		return "//bindtel [1/0]";
	}
}
