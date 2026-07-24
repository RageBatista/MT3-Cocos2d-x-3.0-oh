package fire.util;

import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.xml.DomDriver;

/**
 * XStream实用程序类
 *
 * 统一管理XStream安全配置，防止反序列化攻击
 *
 * @自2025年11月20日起
 * @版本1.0
 */
public class XStreamUtil {

    /**
     * 项目的标准允许类别列表
     */
    private static final String[] STANDARD_ALLOWED_PACKAGES = {
        // 项目内部类
        "fire.pb.**",           // 协议层
        "fire.msp.**",          // 服务层
        "fire.log.**",          // 日志模块
        "fire.util.**",         // 公用事业
        "xbean.**",             // XDB Bean 类
        "xtable.**",            // XDB 表类
        "config.**",            // 配置类

        // Java标准库
        "java.util.**",         // 集合类
        "java.lang.**",         // 基础班
        "java.math.**",         // 数学课
        "java.sql.**"           // 数据库类
    };

    /**
     * 创建标准XStream实例并配置安全策略
     *
     * @return 配置的XStream实例
     */
    public static XStream createXStream() {
        XStream xstream = new XStream();
        XStream.setupDefaultSecurity(xstream);
        xstream.allowTypesByWildcard(STANDARD_ALLOWED_PACKAGES);
        return xstream;
    }

    /**
     * Create a XStream instance with security policy configured (using DomDriver)
     *
     * @return 配置的XStream实例
     */
    public static XStream createXStreamWithDomDriver() {
        XStream xstream = new XStream(new DomDriver());
        XStream.setupDefaultSecurity(xstream);
        xstream.allowTypesByWildcard(STANDARD_ALLOWED_PACKAGES);
        return xstream;
    }

    /**
     * 使用自定义允许的包创建 XStream 实例
     *
     * @param extraPackages 额外允许的包
     * @return 配置的XStream实例
     */
    public static XStream createXStream(String... additionalPackages) {
        XStream xstream = new XStream();
        XStream.setupDefaultSecurity(xstream);

        // 首先允许标准包
        xstream.allowTypesByWildcard(STANDARD_ALLOWED_PACKAGES);

        // 然后允许额外的包
        if (additionalPackages != null && additionalPackages.length > 0) {
            xstream.allowTypesByWildcard(additionalPackages);
        }

        return xstream;
    }

    /**
     * Create a XStream instance with custom allowed packages (using DomDriver)
     *
     * @param extraPackages 额外允许的包
     * @return 配置的XStream实例
     */
    public static XStream createXStreamWithDomDriver(String... additionalPackages) {
        XStream xstream = new XStream(new DomDriver());
        XStream.setupDefaultSecurity(xstream);

        // 首先允许标准包
        xstream.allowTypesByWildcard(STANDARD_ALLOWED_PACKAGES);

        // 然后允许额外的包
        if (additionalPackages != null && additionalPackages.length > 0) {
            xstream.allowTypesByWildcard(additionalPackages);
        }

        return xstream;
    }

    /**
     * 为现有XStream实例配置标准安全策略
     *
     * @param xstream 要配置的XStream实例
     * @return 配置的XStream实例
     */
    public static XStream configureSecurityPolicy(XStream xstream) {
        if (xstream != null) {
            XStream.setupDefaultSecurity(xstream);
            xstream.allowTypesByWildcard(STANDARD_ALLOWED_PACKAGES);
        }
        return xstream;
    }

    /**
     * 获取标准允许的包列表
     *
     * @return 允许的包列表
     */
    public static String[] getStandardAllowedPackages() {
        return STANDARD_ALLOWED_PACKAGES.clone();
    }

    /**
     * Create a XStream instance that allows all types (for testing environment only)
     *
     * 警告：请勿在生产环境中使用！
     *
     * @return 配置的XStream实例
     * @throws SecurityException 如果不在测试环境中
     */
    public static XStream createUnsafeXStream() {
        if (!isTestEnvironment()) {
            throw new SecurityException(
                "Unsafe XStream can only be used in test environment! " +
                "Set system property 'env=test' to enable."
            );
        }

        XStream xstream = new XStream();
        xstream.addPermission(com.thoughtworks.xstream.security.AnyTypePermission.ANY);
        return xstream;
    }

    /**
     * 检查是否是测试环境
     *
     * @return true 如果测试环境
     */
    private static boolean isTestEnvironment() {
        String env = System.getProperty("env");
        return "test".equalsIgnoreCase(env) || "testing".equalsIgnoreCase(env);
    }
}
