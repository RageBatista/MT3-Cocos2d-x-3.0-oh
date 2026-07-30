#include "MT3SpineDiagnostic.h"
#include <stdio.h>
#include <stdarg.h>

void MT3SpineTrace(const char* fmt, ...)
{
	FILE* fp = NULL;
	if (fopen_s(&fp, "spine_draw_debug.log", "ab") != 0 || !fp)
		return;
	va_list args;
	va_start(args, fmt);
	vfprintf(fp, fmt, args);
	va_end(args);
	fputs("\n", fp);
	fclose(fp);
}
