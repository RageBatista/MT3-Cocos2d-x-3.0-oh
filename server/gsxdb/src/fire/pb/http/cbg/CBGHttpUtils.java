package fire.pb.http.cbg;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicNameValuePair;

import fire.pb.http.HttpUtil;
import fire.pb.http.util.LocalHttpUtils;
import fire.pb.main.ConfigManager;
import fire.pb.main.Gs;
import fire.util.JsonUtil;
import com.fasterxml.jackson.databind.node.ObjectNode;

/**
 * 藏宝阁Http请求相关
 * author yebin @ 2016年8月6日
 *
 */
public class CBGHttpUtils {
	// 藏宝阁请求地址
	private static final String CBG_UP_HTTP_URL = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.heishi.up.url");
	private static final String CBG_DOWN_HTTP_URL = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.heishi.down.url");

	/**
	 * 生成Json串用 yebin added @ 2016年8月6日 下午3:44:28
	 * 
	 * @参数映射
	 * @返回
	 */
	private final static String genJsonString(Map<String, Object> map) {
		String msg;
		try {
			msg = JsonUtil.toJsonString(map);
		} catch (Exception e) {
			e.printStackTrace();
			HttpUtil.logger.error("CBGHttpUtils.genJsonString has occur a Exception");
			msg = "";
		}
		return msg;
	}

	/**
	 * 生成商品上架data Json字符串 yebin added @ 2016年8月6日 下午3:40:10
	 *
	 * @参数角色Id
	 * @参数价格
	 * @参数号
	 * @参数宣传
	 * @参数类别
	 * @参数描述
	 * @返回
	 */
	private final static String genItemUpJsonString(long roleId, long price, long num, String pid, int publicity, int category, ObjectNode desc) {
		xbean.Properties prop = xtable.Properties.select(roleId);
		if (prop == null) {
			return null;
		}

		xbean.UserDeviceInfo userinfo = xtable.Userdeviceinfotab.select(prop.getUserid());
		if (userinfo == null) {
			return null;
		}

		if(desc == null) {
			HttpUtil.logger.info("genItemUpJsonString desc is null");
		}
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("roleId", roleId);
		map.put("price", price);
		map.put("num", num);
		map.put("pid", pid);
		map.put("platformId", userinfo.getUsername());
		map.put("publicity", publicity);
		map.put("category", category);
		map.put("serverId", Gs.serverid);
		map.put("desc", desc);

		return genJsonString(map);
	}

	/**
	 * 生成商品上架完整HTTP请求
	 * yebin added @ 2016年8月8日 下午5:51:02
	 * @参数角色Id
	 * @参数价格
	 * @参数号
	 * @参数pid
	 * @参数宣传
	 * @参数类别
	 * @参数描述
	 * @返回
	 */
	public final static HttpPost genItemUpHttpPostRequest(long roleId, long price, long num, String pid, int publicity, int category, ObjectNode desc) {
		String data = genItemUpJsonString(roleId, price, num, pid, publicity, category, desc);
		if (data == null || data.length() == 0) {
			HttpUtil.logger.error("CBGHttpUtils.genItemUpHttpRequest data error!");
			return null;
		}
		
		String sign = LocalHttpUtils.getMD5Str(ConfigManager.getGameKey() + data);
		String dataURLEncodeRst;
		try {
			dataURLEncodeRst = URLEncoder.encode(data, "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			dataURLEncodeRst = "";
			HttpUtil.logger.error("CBGHttpUtils.genItemUpHttpRequestString has occur a error");
		}
		
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("gameId", String.valueOf(ConfigManager.getGameId())));
		params.add(new BasicNameValuePair("command", String.valueOf(101)));
		params.add(new BasicNameValuePair("version", String.valueOf(1000)));
		params.add(new BasicNameValuePair("data", dataURLEncodeRst));
		params.add(new BasicNameValuePair("sign", sign));
		
		HttpPost post = new HttpPost(CBG_UP_HTTP_URL);
		try {
			post.setEntity(new UrlEncodedFormEntity(params));
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return null;
		}
		
		return post;
	}
	
	private final static String genItemDownJsonString(long roleId, String pid) {
		xbean.Properties prop = xtable.Properties.select(roleId);
		if (prop == null) {
			return null;
		}

		xbean.UserDeviceInfo userinfo = xtable.Userdeviceinfotab.select(prop.getUserid());
		if (userinfo == null) {
			return null;
		}

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("platformId", userinfo.getUsername());
		map.put("serverId", Gs.serverid);
		map.put("roleId", roleId);
		map.put("pid", pid);
		
		return genJsonString(map);
	}

	/**
	 * 生成商品下架完整HTTP请求
	 * yebin added @ 2016年8月6日 下午4:20:45
	 * @参数角色Id
	 * @参数pid
	 * @返回
	 */
	public final static HttpPost genItemDownHttpPostRequest(long roleId, String pid) {
		String data = genItemDownJsonString(roleId, pid);
		if (data == null || data.length() == 0) {
			HttpUtil.logger.error("CBGHttpUtils.genItemDownHttpRequest data error!");
			return null;
		}
		
		String sign = LocalHttpUtils.getMD5Str(ConfigManager.getGameKey() + data);
		String dataURLEncodeRst;
		try {
			dataURLEncodeRst = URLEncoder.encode(data, "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			dataURLEncodeRst = "";
			HttpUtil.logger.error("CBGHttpUtils.genItemDownHttpRequest has occur an error");
		}
		
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("gameId", String.valueOf(ConfigManager.getGameId())));
		params.add(new BasicNameValuePair("command", String.valueOf(102)));
		params.add(new BasicNameValuePair("version", String.valueOf(1000)));
		params.add(new BasicNameValuePair("data", dataURLEncodeRst));
		params.add(new BasicNameValuePair("sign", sign));
		
		HttpPost post = new HttpPost(CBG_DOWN_HTTP_URL);
		try {
			post.setEntity(new UrlEncodedFormEntity(params));
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return null;
		}
		return post;
	}
}
