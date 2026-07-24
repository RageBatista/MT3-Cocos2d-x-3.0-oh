#!/bin/bash
# ============================================
# jmxc 项目构建脚本 (Linux/Mac)
# 用途: 清理、编译、打包 jmxc.jar
# ============================================

set -e  # 遇到错误立即退出

echo "[1/4] 清理旧的编译文件..."
rm -rf bin
rm -f jmxc-new.jar
mkdir -p bin

echo "[2/4] 编译 Java 源代码..."
javac -d bin -encoding UTF-8 \
  src/jmxc.java \
  src/ConnectTask.java \
  src/com/jmxservice/mt3interfaces/GameOnlineNumBean.java \
  src/com/jmxservice/mt3interfaces/LogInfo.java

echo "[3/4] 创建 MANIFEST.MF..."
cat > manifest.txt << 'EOF'
Manifest-Version: 1.0
Class-Path: .
Main-Class: jmxc

EOF

echo "[4/4] 打包 JAR 文件..."
jar -cvfm jmxc-new.jar manifest.txt -C bin .

echo ""
echo "============================================"
echo "构建成功！"
echo "新的 jar 文件: jmxc-new.jar"
echo "文件大小:"
ls -lh jmxc-new.jar
echo "============================================"
echo ""

# 清理临时文件
rm -f manifest.txt

echo "[可选] 测试新的 jar 包..."
echo "运行命令: java -jar jmxc-new.jar"
echo ""
