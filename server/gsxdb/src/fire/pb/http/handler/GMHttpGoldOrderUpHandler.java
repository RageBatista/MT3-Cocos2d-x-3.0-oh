/*
 * @作者：错误：错误：git config user.name & 请设置死值或安装 git && 错误：git config user.email & 请设置死值或安装 git & 请设置死值或安装 git
 * @日期：2025-12-30 17:13:08
 * @LastEditors：错误：错误：git config user.name & 请设置死值或安装 git && 错误：git config user.email & 请设置死值或安装 git & 请设置死值或安装 git
 * @LastEditTime: 2026-01-11 11:24:14
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\http\handler\GMHttpGoldOrderUpHandler.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
package fire.pb.http.handler;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.nio.charset.Charset;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import fire.log.Logger;
import com.fasterxml.jackson.databind.node.ObjectNode;
import fire.util.JsonUtil;

/**
 * GM查询在线角色信息 author yebin @ 2016年1月19日
 */
public class GMHttpGoldOrderUpHandler implements HttpHandler {
	public static Logger logger = Logger.getLogger("GMHTTP");

	@Override
	public void handle(HttpExchange exchange) {
		try {
			ObjectNode jsonObj = JsonUtil.createObject();
			exchange.sendResponseHeaders(HttpURLConnection.HTTP_OK, 0);
			final OutputStream os = exchange.getResponseBody();
			jsonObj.put("code", 1);
			jsonObj.put("message", "测试");
			os.write(jsonObj.toString().getBytes(Charset.forName("utf-8")));
		} catch (Exception e) {
			logger.error("GM_HttpToolHandler exception=", e);
		} finally {
			exchange.close();
		}
	}
}
