#pragma once

#include <wx/arrstr.h>
#include <wx/string.h>

struct BuildRequest {
  wxString sourceDir;
  wxString outputDir;
  wxString atlasName;

  int maxWidth = 2048;
  int maxHeight = 2048;
  int borderPadding = 2;
  int shapePadding = 2;

  bool allowRotation = false;
  bool allowTrim = false;
  bool powerOfTwo = false;
  bool autoSplit = true;

  int nativeHorzRes = 1024;
  int nativeVertRes = 768;
};

struct BuildResult {
  bool success = false;
  int exitCode = -1;

  wxString commandLine;
  wxString stdOut;
  wxString stdErr;
  wxString errorMessage;

  wxString outputImagePath;
  wxString outputMetadataXmlPath;
  wxString outputImagesetPath;

  int spriteCount = 0;
  int atlasCount = 0;
  wxArrayString outputImagePaths;
  wxArrayString outputMetadataXmlPaths;
  wxArrayString outputImagesetPaths;
};
