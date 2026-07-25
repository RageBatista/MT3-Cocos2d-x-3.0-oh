#include "MainFrame.h"

#include "BuildTypes.h"
#include "PreviewCanvas.h"
#include "TexturePackerInvoker.h"

#include <windows.h>

#include <wx/filename.h>
#include <wx/frame.h>
#include <wx/image.h>
#include <wx/msgdlg.h>

namespace {

bool HasSwitch(const wxString &name, int argc, wxChar **argv) {
  for (int i = 1; i < argc; ++i) {
    if (wxString(argv[i]).CmpNoCase(name) == 0) {
      return true;
    }
  }
  return false;
}

wxString GetOptionValue(const wxString &name, int argc, wxChar **argv,
                        const wxString &defaultValue = wxEmptyString) {
  const wxString prefix = name + wxT("=");
  for (int i = 1; i < argc; ++i) {
    const wxString arg(argv[i]);
    if (arg.StartsWith(prefix)) {
      return arg.Mid(prefix.Length());
    }
  }
  return defaultValue;
}

wxString DefaultSmokeSourceDir() {
  return wxGetCwd() +
         wxT("\\tools\\free-tex-packer\\src\\client\\resources\\static\\images\\browser");
}

wxString DefaultSmokeOutDir() {
  return wxGetCwd() + wxT("\\tools\\TexturePacker_CEGUI\\workspace\\smoke-out");
}

wxString DefaultPackOutDir() {
  return wxGetCwd() + wxT("\\client\\resource\\res\\ui\\imagesets");
}

bool ParseIntOption(const wxString &name, int argc, wxChar **argv,
                    int defaultValue, int minValue, int &outValue,
                    wxString &errorMessage) {
  const wxString raw = GetOptionValue(name, argc, argv, wxEmptyString);
  if (raw.IsEmpty()) {
    outValue = defaultValue;
    return true;
  }

  long parsed = 0;
  if (!raw.ToLong(&parsed)) {
    errorMessage = wxT("参数解析失败: ") + name + wxT("=\"") + raw + wxT("\"");
    return false;
  }

  if (parsed < minValue) {
    errorMessage = wxString::Format(wxT("参数 %s 不能小于 %d。"), name.c_str(),
                                    minValue);
    return false;
  }

  outValue = static_cast<int>(parsed);
  return true;
}

void PrintPackUsage() {
  wxFprintf(stdout, wxT("TexturePacker_CEGUI CLI\n"));
  wxFprintf(stdout, wxT("用法:\n"));
  wxFprintf(stdout,
            wxT("  --pack --src=<dir> [--out=<dir>] [--atlas=<name>]\n"));
  wxFprintf(stdout, wxT("         [--max-width=<int>] [--max-height=<int>]\n"));
  wxFprintf(stdout,
            wxT("         [--border-padding=<int>] [--shape-padding=<int>]\n"));
  wxFprintf(stdout,
            wxT("         [--native-horz-res=<int>] [--native-vert-res=<int>]\n"));
  wxFprintf(stdout, wxT("         [--allow-trim] [--allow-rotation] [--power-of-two] [--no-auto-split]\n"));
  wxFprintf(stdout, wxT("示例:\n"));
  wxFprintf(stdout,
            wxT("  TexturePacker_CEGUI.exe --pack --src=art/ui/common ")
            wxT("--out=client/resource/res/ui/imagesets --atlas=common_pack\n"));
}

void ExitNow(UINT code) {
  ::ExitProcess(code);
}

} // namespace

class TexturePackerCEGUIApp : public wxApp {
public:
  virtual bool OnInit() override {
    wxInitAllImageHandlers();

    const bool showHelp = HasSwitch(wxT("--help"), argc, argv) ||
                          HasSwitch(wxT("-h"), argc, argv) ||
                          HasSwitch(wxT("/?"), argc, argv);
    const bool smokeUi = HasSwitch(wxT("--smoke-ui"), argc, argv);
    const bool smokePack = HasSwitch(wxT("--smoke-pack"), argc, argv);
    const bool pack = HasSwitch(wxT("--pack"), argc, argv);

    if (showHelp) {
      PrintPackUsage();
      ExitNow(0);
    }

    if (smokeUi) {
      wxFrame *host = new wxFrame(NULL, wxID_ANY, wxT("SmokeUIHost"),
                                  wxDefaultPosition, wxSize(640, 480));
      PreviewCanvas *canvas = new PreviewCanvas(host);

      wxString error;
      const bool ok = canvas->InitialiseCEGUI(error);

      delete host;

      if (!ok) {
        wxFprintf(stderr, wxT("SMOKE_UI_FAIL: %s\n"), error.c_str());
        ExitNow(11);
      }

      wxFprintf(stdout, wxT("SMOKE_UI_PASS\n"));
      ExitNow(0);
    }

    if (smokePack) {
      BuildRequest req;
      req.sourceDir = GetOptionValue(wxT("--src"), argc, argv,
                                     DefaultSmokeSourceDir());
      req.outputDir =
          GetOptionValue(wxT("--out"), argc, argv, DefaultSmokeOutDir());
      req.atlasName =
          GetOptionValue(wxT("--atlas"), argc, argv, wxT("tp_cegui_smoke"));

      const BuildResult result = TexturePackerInvoker::Run(req);

      if (!result.stdOut.IsEmpty()) {
        wxFprintf(stdout, wxT("%s\n"), result.stdOut.c_str());
      }
      if (!result.stdErr.IsEmpty()) {
        wxFprintf(stderr, wxT("%s\n"), result.stdErr.c_str());
      }

      if (!result.success) {
        wxFprintf(stderr, wxT("SMOKE_PACK_FAIL: %s\n"),
                  result.errorMessage.c_str());
        ExitNow(12);
      }

      wxFprintf(stdout, wxT("SMOKE_PACK_PASS: %s\n"),
                result.outputImagesetPath.c_str());
      ExitNow(0);
    }

    if (pack) {
      BuildRequest req;
      req.sourceDir = GetOptionValue(wxT("--src"), argc, argv, wxEmptyString);
      req.outputDir =
          GetOptionValue(wxT("--out"), argc, argv, DefaultPackOutDir());
      req.atlasName = GetOptionValue(wxT("--atlas"), argc, argv, wxT("ui_atlas"));

      req.allowTrim = HasSwitch(wxT("--allow-trim"), argc, argv);
      req.allowRotation = HasSwitch(wxT("--allow-rotation"), argc, argv);
      req.powerOfTwo = HasSwitch(wxT("--power-of-two"), argc, argv);
      req.autoSplit = !HasSwitch(wxT("--no-auto-split"), argc, argv);

      wxString parseError;
      if (!ParseIntOption(wxT("--max-width"), argc, argv, req.maxWidth, 1,
                          req.maxWidth, parseError) ||
          !ParseIntOption(wxT("--max-height"), argc, argv, req.maxHeight, 1,
                          req.maxHeight, parseError) ||
          !ParseIntOption(wxT("--border-padding"), argc, argv,
                          req.borderPadding, 0, req.borderPadding, parseError) ||
          !ParseIntOption(wxT("--shape-padding"), argc, argv, req.shapePadding,
                          0, req.shapePadding, parseError) ||
          !ParseIntOption(wxT("--native-horz-res"), argc, argv,
                          req.nativeHorzRes, 1, req.nativeHorzRes, parseError) ||
          !ParseIntOption(wxT("--native-vert-res"), argc, argv,
                          req.nativeVertRes, 1, req.nativeVertRes, parseError)) {
        wxFprintf(stderr, wxT("PACK_FAIL: %s\n"), parseError.c_str());
        PrintPackUsage();
        ExitNow(21);
      }

      if (req.sourceDir.IsEmpty()) {
        wxFprintf(stderr, wxT("PACK_FAIL: 缺少必填参数 --src\n"));
        PrintPackUsage();
        ExitNow(21);
      }

      const BuildResult result = TexturePackerInvoker::Run(req);

      if (!result.stdOut.IsEmpty()) {
        wxFprintf(stdout, wxT("%s\n"), result.stdOut.c_str());
      }
      if (!result.stdErr.IsEmpty()) {
        wxFprintf(stderr, wxT("%s\n"), result.stdErr.c_str());
      }

      if (!result.success) {
        wxFprintf(stderr, wxT("PACK_FAIL: %s\n"), result.errorMessage.c_str());
        ExitNow(22);
      }

      wxFprintf(stdout, wxT("PACK_PASS: %s\n"), result.outputImagesetPath.c_str());
      wxFprintf(stdout, wxT("PACK_PAGES: %d\n"), result.atlasCount);
      for (size_t i = 0; i < result.outputImagesetPaths.Count(); ++i) {
        wxFprintf(stdout, wxT("PACK_IMAGESET: %s\n"),
                  result.outputImagesetPaths[i].c_str());
      }

      ExitNow(0);
    }

    MainFrame *frame = new MainFrame();

    wxString previewInitError;
    if (!frame->InitializePreview(previewInitError)) {
      wxMessageBox(wxT("CEGUI 初始化失败:\n") + previewInitError,
                   wxT("TexturePacker_CEGUI 启动失败"),
                   wxOK | wxICON_ERROR);
      delete frame;
      return false;
    }

    frame->Show(true);
    SetTopWindow(frame);

    return true;
  }
};

wxIMPLEMENT_APP(TexturePackerCEGUIApp);
