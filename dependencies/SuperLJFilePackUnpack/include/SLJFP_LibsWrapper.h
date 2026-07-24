/**
 * @file SLJFP_LibsWrapper.h
 * @brief Wrapper functions for external libraries (header)
 * @version 1.0
 * @date 2025-01-03
 */

#ifndef SLJFP_LIBSWRAPPER_H
#define SLJFP_LIBSWRAPPER_H

#include <string>

#ifdef __cplusplus
extern "C" {
#endif

// MiniZ wrapper functions
unsigned int SLJFP_mz_compress2(unsigned char *pDest, unsigned int *pDest_len,
                                const unsigned char *pSource, unsigned int source_len, int level);

unsigned int SLJFP_mz_uncompress(unsigned char *pDest, unsigned int *pDest_len,
                                  const unsigned char *pSource, unsigned int source_len);

// SMS4 wrapper functions
void SLJFP_SMS4Ex(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);

void SLJFP_DeSMS4Ex(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);
void SLJFP_DeSMS4ExLegacy(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);
void SLJFP_DeSMS4ExClientObf(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);
void SLJFP_DeSMS4BlocksLegacy(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);
void SLJFP_DeSMS4BlocksClientObf(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);
void SLJFP_DeSMS4BlocksClientKeyed(unsigned char* pInData, unsigned char* pOutData, unsigned int nDataLen, std::string strKey);

// CRC32 wrapper function
unsigned int SLJFP_crc32(unsigned int crc, const unsigned char *ptr, unsigned int buf_len);

#ifdef __cplusplus
}
#endif

#endif // SLJFP_LIBSWRAPPER_H
