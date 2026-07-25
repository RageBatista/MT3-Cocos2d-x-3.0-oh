using System;
using System.Windows.Forms;

namespace LJFilePackUnpacker.MvpGui;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
    }
}
