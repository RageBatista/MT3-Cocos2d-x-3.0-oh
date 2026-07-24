#include <SuperLJFilePackUnpack/SLJFP_Unpack.h>
#include <SuperLJFilePackUnpack/SLJFP_LibsWrapper.h>

int main() {
    const unsigned char sample[] = { 'm', 't', '3' };

    SLJFP::UnpackOptions options;
    const unsigned int crc = SLJFP_crc32(0, sample, static_cast<unsigned int>(sizeof(sample)));

    if (options.threadCount != 1) {
        return 1;
    }

    return crc == 0 ? 2 : 0;
}
