#ifndef LJFP_SMS4_H
#define LJFP_SMS4_H

#include <string>
#include <cstdint>
#include <cstring>

#define ROUND            32

static unsigned int FK[4]={
    0xA3B1BAC6,0x56AA3350,0x677D9197,0xB27022DC
};

static unsigned int CK[ROUND]={
    0x00070e15, 0x1c232a31, 0x383f464d, 0x545b6269,
    0x70777e85, 0x8c939aa1, 0xa8afb6bd, 0xc4cbd2d9,
    0xe0e7eef5, 0xfc030a11, 0x181f262d, 0x343b4249,
    0x50575e65, 0x6c737a81, 0x888f969d, 0xa4abb2b9,
    0xc0c7ced5, 0xdce3eaf1, 0xf8ff060d, 0x141b2229,
    0x30373e45, 0x4c535a61, 0x686f767d, 0x848b9299,
    0xa0a7aeb5, 0xbcc3cad1, 0xd8dfe6ed, 0xf4fb0209,
    0x10171e25, 0x2c333a41, 0x484f565d, 0x646b7279
};

static unsigned char Sbox1[256]={
    0xd6,0x90,0xe9,0xfe,0xcc,0xe1,0x3d,0xb7,0x16,0xb6,0x14,0xc2,0x28,0xfb,0x2c,0x05,
    0x2b,0x67,0x9a,0x76,0x2a,0xbe,0x04,0xc3,0xaa,0x44,0x13,0x26,0x49,0x86,0x06,0x99,
    0x9c,0x42,0x50,0xf4,0x91,0xef,0x98,0x7a,0x33,0x54,0x0b,0x43,0xed,0xcf,0xac,0x62,
    0xe4,0xb3,0x1c,0xa9,0xc9,0x08,0xe8,0x95,0x80,0xdf,0x94,0xfa,0x75,0x8f,0x3f,0xa6,
    0x47,0x07,0xa7,0xfc,0xf3,0x73,0x17,0xba,0x83,0x59,0x3c,0x19,0xe6,0x85,0x4f,0xa8,
    0x68,0x6b,0x81,0xb2,0x71,0x64,0xda,0x8b,0xf8,0xeb,0x0f,0x4b,0x70,0x56,0x9d,0x35,
    0x1e,0x24,0x0e,0x5e,0x63,0x58,0xd1,0xa2,0x25,0x22,0x7c,0x3b,0x01,0x21,0x78,0x87,
    0xd4,0x00,0x46,0x57,0x9f,0xd3,0x27,0x52,0x4c,0x36,0x02,0xe7,0xa0,0xc4,0xc8,0x9e,
    0xea,0xbf,0x8a,0xd2,0x40,0xc7,0x38,0xb5,0xa3,0xf7,0xf2,0xce,0xf9,0x61,0x15,0xa1,
    0xe0,0xae,0x5d,0xa4,0x9b,0x34,0x1a,0x55,0xad,0x93,0x32,0x30,0xf5,0x8c,0xb1,0xe3,
    0x1d,0xf6,0xe2,0x2e,0x82,0x66,0xca,0x60,0xc0,0x29,0x23,0xab,0x0d,0x53,0x4e,0x6f,
    0xd5,0xdb,0x37,0x45,0xde,0xfd,0x8e,0x2f,0x03,0xff,0x6a,0x72,0x6d,0x6c,0x5b,0x51,
    0x8d,0x1b,0xaf,0x92,0xbb,0xdd,0xbc,0x7f,0x11,0xd9,0x5c,0x41,0x1f,0x10,0x5a,0xd8,
    0x0a,0xc1,0x31,0x88,0xa5,0xcd,0x7b,0xbd,0x2d,0x74,0xd0,0x12,0xb8,0xe5,0xb4,0xb0,
    0x89,0x69,0x97,0x4a,0x0c,0x96,0x77,0x7e,0x65,0xb9,0xf1,0x09,0xc5,0x6e,0xc6,0x84,
    0x18,0xf0,0x7d,0xec,0x3a,0xdc,0x4d,0x20,0x79,0xee,0x5f,0x3e,0xd7,0xcb,0x39,0x48
};

#define ROL(x,y)    ((x)<<(y) |    (x)>>(32-(y)))


class SMS4
{
public:
	SMS4(unsigned char* Mkey)
	{
		for (int i = 0; i <= 3; i++)
		{
			m_Key[i] = Mkey[i * 4 + 0] << 24 | Mkey[i * 4 + 1] << 16 | Mkey[i * 4 + 2] << 8 | Mkey[i * 4 + 3];
		}

		KeyExpansion();
	}
	~SMS4(void)
	{
	}
	void KeyExpansion()
	{
		unsigned int    K[4] = { 0 };
		int        i = 0;

		for (i = 0; i < 4; i++)
		{
			K[i] = m_Key[i] ^ FK[i];
		}

		for (i = 0; i < ROUND; i++)
		{
			K[i % 4] ^= T2(K[(i + 1) % 4] ^ K[(i + 2) % 4] ^ K[(i + 3) % 4] ^ CK[i]);
			mRK[i] = K[i % 4];
		}
	}
	unsigned int T1(unsigned int dwA)
	{
		unsigned char    a0[4] = { 0 };
		unsigned char    b0[4] = { 0 };
		unsigned int    dwB = 0;
		unsigned int    dwC = 0;
		int                i = 0;

		for (i = 0; i < 4; i++)
		{
			a0[i] = (dwA >> (i * 8)) & 0xff;
			b0[i] = Sbox1[a0[i]];
			dwB |= (b0[i] << (i * 8));
		}

		dwC = dwB^ROL(dwB, 2) ^ ROL(dwB, 10) ^ ROL(dwB, 18) ^ ROL(dwB, 24);

		return dwC;
	}
	unsigned int T2(unsigned int dwA)
	{
		unsigned char    a0[4] = { 0 };
		unsigned char    b0[4] = { 0 };
		unsigned int    dwB = 0;
		unsigned int    dwC = 0;
		int		i = 0;

		for (i = 0; i < 4; i++)
		{
			a0[i] = (dwA >> (i * 8)) & 0xff;
			b0[i] = Sbox1[a0[i]];
			dwB |= (b0[i] << (i * 8));
		}

		dwC = dwB^ROL(dwB, 13) ^ ROL(dwB, 23);

		return dwC;
	}
	void Cipher(unsigned char* inBuff, unsigned char* ouBuff)
	{
		unsigned int X[4] = { 0 };
		unsigned int Y[4] = { 0 };
		for (int i = 0; i < 4; i++)
		{
			X[i + 0] = inBuff[i * 4 + 0] << 24 | inBuff[i * 4 + 1] << 16 | inBuff[i * 4 + 2] << 8 | inBuff[i * 4 + 3];
		}
		unsigned int    tempX[4] = { 0 };
		int                i = 0;

		for (i = 0; i < 4; i++)
		{
			tempX[i] = X[i];
		}

		for (i = 0; i < ROUND; i++)
		{
			tempX[i % 4] ^= T1(tempX[(i + 1) % 4] ^ tempX[(i + 2) % 4] ^ tempX[(i + 3) % 4] ^ mRK[i]);
		}

		for (i = 0; i < 4; i++)
		{
			Y[i] = tempX[3 - i];
		}
		for (int j = 0; j < 4; j++)
		{
			ouBuff[4 * j] = (Y[j] >> 24) & 0xff;
			ouBuff[4 * j + 1] = (Y[j] >> 16) & 0xff;
			ouBuff[4 * j + 2] = (Y[j] >> 8) & 0xff;
			ouBuff[4 * j + 3] = Y[j] & 0xff;
		}
	}
	void InvCipher(unsigned char* inBuff, unsigned char* ouBuff)
	{
		unsigned int X[4] = { 0 };
		unsigned int Y[4] = { 0 };
		for (int i = 0; i < 4; i++)
		{
			X[i + 0] = inBuff[i * 4 + 0] << 24 | inBuff[i * 4 + 1] << 16 | inBuff[i * 4 + 2] << 8 | inBuff[i * 4 + 3];
		}
		for (int i = 0; i < 4; i++)
		{
			Y[i + 0] = ouBuff[i * 4 + 0] << 24 | ouBuff[i * 4 + 1] << 16 | ouBuff[i * 4 + 2] << 8 | ouBuff[i * 4 + 3];
		}
		unsigned int    tempX[4] = { 0 };
		int                i = 0;

		for (i = 0; i < 4; i++)
		{
			tempX[i] = X[i];
		}

		for (i = 0; i < ROUND; i++)
		{
			tempX[i % 4] ^= T1(tempX[(i + 1) % 4] ^ tempX[(i + 2) % 4] ^ tempX[(i + 3) % 4] ^ mRK[(31 - i)]);
		}

		for (i = 0; i < 4; i++)
		{
			Y[i] = tempX[3 - i];
		}
		for (int j = 0; j < 4; j++)
		{
			ouBuff[4 * j] = (Y[j] >> 24) & 0xff;
			ouBuff[4 * j + 1] = (Y[j] >> 16) & 0xff;
			ouBuff[4 * j + 2] = (Y[j] >> 8) & 0xff;
			ouBuff[4 * j + 3] = Y[j] & 0xff;
		}
	}

private:
	unsigned int m_Key[4];

	unsigned int mRK[32];

};
inline void SMS4Byte16Arr(unsigned char* inBuff, unsigned char* ouBuff, int iByte16Count, std::string strPassword)
{
	unsigned char ucPassword[16];
	for (int i = 0; i < 16; i++)
	{
		if (i >= static_cast<int>(strPassword.size()))
		{
			ucPassword[i] = 0;
		}
		else
		{
			ucPassword[i] = strPassword[i];
		}
	}
	SMS4 S4(ucPassword);
	for (int i = 0; i < iByte16Count; i++)
	{
		S4.Cipher(inBuff + i * 16, ouBuff + i * 16);
	}
}
inline void SMS4Ex(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	int iByte16Count = 0;
	int iByteLastCount = 0;
	if (uiSize >= 1024)
	{
		iByteLastCount = uiSize - 1024;
		uiSize = 1024;
	}
	else
	{
		iByteLastCount = uiSize % 16;
	}
	iByte16Count = uiSize / 16;
	SMS4Byte16Arr(inBuff, ouBuff, iByte16Count, strPassword);
	if (iByteLastCount > 0)
	{
		memcpy(ouBuff + iByte16Count * 16, inBuff + iByte16Count * 16, iByteLastCount);
	}
}
inline void DeSMS4Byte16Arr_Legacy(unsigned char* inBuff, unsigned char* ouBuff, int iByte16Count, std::string strPassword)
{
	unsigned char ucPassword[16];
	for (int i = 0; i < 16; i++)
	{
		if (i >= static_cast<int>(strPassword.size()))
		{
			ucPassword[i] = 0;
		}
		else
		{
			ucPassword[i] = strPassword[i];
		}
	}
	SMS4 S4(ucPassword);
	for (int i = 0; i < iByte16Count; i++)
	{
		S4.InvCipher(inBuff + i * 16, ouBuff + i * 16);
	}
}

inline void BuildClientKeyWords_FixedObf(std::uint32_t outKeyWords[4])
{
	static const std::uint32_t kObfuscatedKeyWords[4] = {
		0x18151f19u, 0x0900050au, 0x040e1217u, 0x140b020fu
	};
	std::memcpy(outKeyWords, kObfuscatedKeyWords, sizeof(kObfuscatedKeyWords));
}

inline void BuildClientKeyWords_FromPassword(const std::string& strPassword,
	                                         std::uint32_t outKeyWords[4])
{
	unsigned char rawKeyBytes[16];
	std::memset(rawKeyBytes, 0, sizeof(rawKeyBytes));

	size_t copySize = strPassword.size();
	if (copySize > sizeof(rawKeyBytes))
	{
		copySize = sizeof(rawKeyBytes);
	}
	if (copySize > 0)
	{
		std::memcpy(rawKeyBytes, strPassword.data(), copySize);
	}

	for (int i = 0; i < 4; ++i)
	{
		const unsigned char* word = rawKeyBytes + i * 4;
		outKeyWords[i] = static_cast<std::uint32_t>(word[0]) |
			(static_cast<std::uint32_t>(word[1]) << 8) |
			(static_cast<std::uint32_t>(word[2]) << 16) |
			(static_cast<std::uint32_t>(word[3]) << 24);
	}
}

inline void DecryptClient128BlockWithKeyWords(const unsigned char* in,
	                                          unsigned char* out,
	                                          const std::uint32_t keyWords[4])
{
	static const std::uint32_t kInitSum = 0x8dde6e40u;
	static const std::uint32_t kDelta = 0x61c88647u;
	static const std::uint32_t kRoundStep = 0xc3910c8eu;

	std::uint32_t v0 = static_cast<std::uint32_t>(in[0]) |
		(static_cast<std::uint32_t>(in[1]) << 8) |
		(static_cast<std::uint32_t>(in[2]) << 16) |
		(static_cast<std::uint32_t>(in[3]) << 24);
	std::uint32_t v1 = static_cast<std::uint32_t>(in[4]) |
		(static_cast<std::uint32_t>(in[5]) << 8) |
		(static_cast<std::uint32_t>(in[6]) << 16) |
		(static_cast<std::uint32_t>(in[7]) << 24);
	std::uint32_t v2 = static_cast<std::uint32_t>(in[8]) |
		(static_cast<std::uint32_t>(in[9]) << 8) |
		(static_cast<std::uint32_t>(in[10]) << 16) |
		(static_cast<std::uint32_t>(in[11]) << 24);
	std::uint32_t v3 = static_cast<std::uint32_t>(in[12]) |
		(static_cast<std::uint32_t>(in[13]) << 8) |
		(static_cast<std::uint32_t>(in[14]) << 16) |
		(static_cast<std::uint32_t>(in[15]) << 24);

	std::uint32_t sum = kInitSum;
	while (sum != 0u)
	{
		const std::uint32_t sumPlus = sum + kDelta;
		const std::uint32_t idx0 = (sum >> 21) & 0x3u;
		const std::uint32_t idx1 = (sumPlus >> 11) & 0x3u;

		const std::uint32_t m0 = ((((v2 << 4) ^ (v2 >> 5)) + v2) ^
			(sum + keyWords[idx0]));
		const std::uint32_t m1 = ((((v0 << 4) ^ (v0 >> 5)) + v0) ^
			(sumPlus + keyWords[idx1]));

		v3 -= m0;
		v1 -= m1;
		sum += kRoundStep;

		const std::uint32_t idx2 = (sumPlus >> 16) & 0x3u;
		const std::uint32_t idx3 = sum & 0x3u;
		const std::uint32_t m2 = ((((v3 << 4) ^ (v3 >> 5)) + v3) ^
			(sumPlus + keyWords[idx2]));
		const std::uint32_t m3 = ((((v1 << 4) ^ (v1 >> 5)) + v1) ^
			(sum + keyWords[idx3]));

		v2 -= m2;
		v0 -= m3;
	}

	out[0] = static_cast<unsigned char>(v0 & 0xffu);
	out[1] = static_cast<unsigned char>((v0 >> 8) & 0xffu);
	out[2] = static_cast<unsigned char>((v0 >> 16) & 0xffu);
	out[3] = static_cast<unsigned char>((v0 >> 24) & 0xffu);
	out[4] = static_cast<unsigned char>(v1 & 0xffu);
	out[5] = static_cast<unsigned char>((v1 >> 8) & 0xffu);
	out[6] = static_cast<unsigned char>((v1 >> 16) & 0xffu);
	out[7] = static_cast<unsigned char>((v1 >> 24) & 0xffu);
	out[8] = static_cast<unsigned char>(v2 & 0xffu);
	out[9] = static_cast<unsigned char>((v2 >> 8) & 0xffu);
	out[10] = static_cast<unsigned char>((v2 >> 16) & 0xffu);
	out[11] = static_cast<unsigned char>((v2 >> 24) & 0xffu);
	out[12] = static_cast<unsigned char>(v3 & 0xffu);
	out[13] = static_cast<unsigned char>((v3 >> 8) & 0xffu);
	out[14] = static_cast<unsigned char>((v3 >> 16) & 0xffu);
	out[15] = static_cast<unsigned char>((v3 >> 24) & 0xffu);
}

inline void DeSMS4Byte16Arr_ClientObf(unsigned char* inBuff, unsigned char* ouBuff, int iByte16Count, std::string strPassword)
{
	// 与客户端 libgame.so: xxxx_decrypt_128 + obfuscated(16B) 固定链路对齐。
	(void)strPassword;
	std::uint32_t keyWords[4];
	BuildClientKeyWords_FixedObf(keyWords);

	for (int i = 0; i < iByte16Count; ++i)
	{
		DecryptClient128BlockWithKeyWords(inBuff + i * 16, ouBuff + i * 16, keyWords);
	}
}

inline void DeSMS4Byte16Arr_ClientKeyed(unsigned char* inBuff,
	                                   unsigned char* ouBuff,
	                                   int iByte16Count,
	                                   std::string strPassword)
{
	std::uint32_t keyWords[4];
	BuildClientKeyWords_FromPassword(strPassword, keyWords);

	for (int i = 0; i < iByte16Count; ++i)
	{
		DecryptClient128BlockWithKeyWords(inBuff + i * 16, ouBuff + i * 16, keyWords);
	}
}

inline void DeSMS4Blocks_Legacy(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	const int blockCount = static_cast<int>(uiSize / 16u);
	if (blockCount <= 0)
	{
		return;
	}
	DeSMS4Byte16Arr_Legacy(inBuff, ouBuff, blockCount, strPassword);
}

inline void DeSMS4Blocks_ClientObf(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	const int blockCount = static_cast<int>(uiSize / 16u);
	if (blockCount <= 0)
	{
		return;
	}
	DeSMS4Byte16Arr_ClientObf(inBuff, ouBuff, blockCount, strPassword);
}

inline void DeSMS4Blocks_ClientKeyed(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	const int blockCount = static_cast<int>(uiSize / 16u);
	if (blockCount <= 0)
	{
		return;
	}
	DeSMS4Byte16Arr_ClientKeyed(inBuff, ouBuff, blockCount, strPassword);
}

inline void DeSMS4Ex_Legacy(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	unsigned int processSize = uiSize;
	unsigned int copyTail = 0;
	if (processSize >= 1024u)
	{
		copyTail = processSize - 1024u;
		processSize = 1024u;
	}
	else
	{
		copyTail = processSize % 16u;
	}

	const int blockCount = static_cast<int>(processSize / 16u);
	DeSMS4Byte16Arr_Legacy(inBuff, ouBuff, blockCount, strPassword);
	if (copyTail > 0u)
	{
		std::memcpy(ouBuff + blockCount * 16, inBuff + blockCount * 16, copyTail);
	}
}

inline void DeSMS4Ex_ClientObf(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	// 与客户端 LJDeSMS4Func 对齐：仅前 1024 字节参与 16B 分组解密，其余直接拷贝。
	unsigned int processSize = uiSize;
	unsigned int copyTail = 0;
	if (processSize >= 1024u)
	{
		copyTail = processSize - 1024u;
		processSize = 1024u;
	}
	else
	{
		copyTail = processSize % 16u;
	}

	const int blockCount = static_cast<int>(processSize / 16u);
	DeSMS4Byte16Arr_ClientObf(inBuff, ouBuff, blockCount, strPassword);
	if (copyTail > 0u)
	{
		std::memcpy(ouBuff + blockCount * 16, inBuff + blockCount * 16, copyTail);
	}
}

inline void DeSMS4Ex(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword)
{
	// 默认保持与 LJFilePack 原始链路兼容。
	DeSMS4Ex_Legacy(inBuff, ouBuff, uiSize, strPassword);
}

#endif //LJFP_SMS4_H
