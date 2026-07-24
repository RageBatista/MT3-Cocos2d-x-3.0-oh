#ifndef SLJFP_ANDROID_BINARY_KEY_H
#define SLJFP_ANDROID_BINARY_KEY_H

#include <string>

namespace SLJFP {

struct AndroidBinaryKeyProbeResult {
    bool found;
    std::string libgamePath;
    std::string decryptKey;
    std::string message;

    AndroidBinaryKeyProbeResult()
        : found(false) {}
};

bool TryExtractAndroidLibgameDecryptKey(const std::string& libgamePath,
                                        std::string& outKey,
                                        std::string* outMessage = NULL);

bool TryResolveAndroidLibgameDecryptKey(const std::string& resourcePathOrDir,
                                        const std::string& explicitLibgamePathOrDir,
                                        AndroidBinaryKeyProbeResult& outResult);

} // namespace SLJFP

#endif // SLJFP_ANDROID_BINARY_KEY_H
