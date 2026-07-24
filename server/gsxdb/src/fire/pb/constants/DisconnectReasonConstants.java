//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.constants;

public class DisconnectReasonConstants {
    public static final int REASON_PEER_CLOSE = 0;
    public static final int REASON_NETWORK_DISCONNECT = 1;
    public static final int REASON_SERVER_DISCONNECT = 2;
    public static final int REASON_PROTOCOL_MISMATCH = 3;
    public static final int REASON_PROTOCOL_ANOMALY = 4;
    public static final int REASON_AUTH_FAILED = 5;
    public static final int REASON_PACKET_TOO_LARGE = 6;
    public static final int REASON_CONNECTION_TIMEOUT = 7;
    public static final int REASON_SERVER_OVERLOAD = 8;
    public static final int REASON_DUPLICATE_LOGIN = 9;

    public static String getReasonDescription(int reason) {
        switch (reason) {
            case 0:
                return "对端正常关闭连接";
            case 1:
                return "网络层连接断开";
            case 2:
                return "服务器主动断开连接";
            case 3:
                return "协议版本不匹配";
            case 4:
                return "协议处理异常或频繁操作";
            case 5:
                return "认证失败";
            case 6:
                return "数据包过大";
            case 7:
                return "连接超时";
            case 8:
                return "服务器过载";
            case 9:
                return "重复登录";
            default:
                return "未知原因(" + reason + ")";
        }
    }

    public static boolean isHighPriorityReason(int reason) {
        return reason == 4 || reason == 8 || reason == 6;
    }

    public static boolean isNormalDisconnect(int reason) {
        return reason == 0 || reason == 9;
    }

    public static int getSeverityLevel(int reason) {
        switch (reason) {
            case 0:
            case 9:
                return 1;
            case 1:
            case 7:
                return 2;
            case 2:
            case 3:
            case 5:
                return 3;
            case 4:
            case 6:
            case 8:
                return 4;
            default:
                return 3;
        }
    }

    public static String getSuggestedSolution(int reason) {
        switch (reason) {
            case 0:
                return "正常断开，无需处理";
            case 1:
                return "检查网络连接稳定性，确认客户端运行状态";
            case 2:
                return "检查服务器日志，确认断开原因";
            case 3:
                return "确保客户端版本与服务器匹配，检查协议定义";
            case 4:
                return "添加操作频率限制，优化数据传输，检查协议处理逻辑";
            case 5:
                return "重新登录获取有效凭证";
            case 6:
                return "实现数据分页传输，压缩数据包";
            case 7:
                return "优化心跳机制，检查网络延迟";
            case 8:
                return "检查服务器性能，考虑扩容或负载均衡";
            case 9:
                return "正常的重复登录保护，无需处理";
            default:
                return "查看详细日志，分析具体原因";
        }
    }
}
