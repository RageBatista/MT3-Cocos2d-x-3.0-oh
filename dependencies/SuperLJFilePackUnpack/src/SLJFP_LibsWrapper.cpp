/**
 * @file SLJFP_LibsWrapper.cpp
 * @brief Wrapper functions for external libraries
 * @version 1.0
 * @date 2025-01-03
 *
 * This file provides wrapper functions for MiniZ, SMS4, and CRC32 libraries
 * to avoid multiple definition linker errors when linking static library.
 */

#include <string>
#include "../libs/ljfp/LJFP_MiniZ.h"
#include "../libs/ljfp/LJFP_SMS4.h"
#include "../libs/ljfp/LJFP_CRC32.h"

extern "C" {

// MiniZ wrapper functions
unsigned int SLJFP_mz_compress2(unsigned char *pDest, unsigned int *pDest_len,
                                const unsigned char *pSource, unsigned int source_len, int level) {
    return mz_compress2(pDest, (mz_ulong*)pDest_len, pSource, source_len, level);
}

unsigned int SLJFP_mz_uncompress(unsigned char *pDest, unsigned int *pDest_len,
                                  const unsigned char *pSource, unsigned int source_len) {
    return mz_uncompress(pDest, (mz_ulong*)pDest_len, pSource, source_len);
}

// SMS4 wrapper functions
void SLJFP_SMS4Ex(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    SMS4Ex(pInData, pOutData, nDataLen, strKey);
}

void SLJFP_DeSMS4Ex(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    DeSMS4Ex(pInData, pOutData, nDataLen, strKey);
}

void SLJFP_DeSMS4ExLegacy(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    DeSMS4Ex_Legacy(pInData, pOutData, nDataLen, strKey);
}

void SLJFP_DeSMS4ExClientObf(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    DeSMS4Ex_ClientObf(pInData, pOutData, nDataLen, strKey);
}

void SLJFP_DeSMS4BlocksLegacy(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    DeSMS4Blocks_Legacy(pInData, pOutData, nDataLen, strKey);
}

void SLJFP_DeSMS4BlocksClientObf(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    DeSMS4Blocks_ClientObf(pInData, pOutData, nDataLen, strKey);
}

void SLJFP_DeSMS4BlocksClientKeyed(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey) {
    DeSMS4Blocks_ClientKeyed(pInData, pOutData, nDataLen, strKey);
}

// CRC32 wrapper function
unsigned int SLJFP_crc32(unsigned int crc, const unsigned char *ptr, unsigned int buf_len) {
    return crc32(crc, ptr, buf_len);
}

} // extern "C"
