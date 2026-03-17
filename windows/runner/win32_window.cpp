#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

window_proc_delegate g_window_proc_delegate = nullptr;

void EnableFullDpiSupportIfAvailable(HWND hwnd) {
  HMODULE user32_module = LoadLibraryA("User32.dll");
  if (!user32_module) {
    return;
  }
  auto enable_non_client_dpi_scaling =
      reinterpret_cast<BOOL(__stdcall*)(HWND)>(
          GetProcAddress(user32_module, "EnableNonClientDpiScaling"));
  if (enable_non_client_dpi_scaling != nullptr) {
    enable_non_client_dpi_scaling(hwnd);
  }
  FreeLibrary(user32_module);
}

}  // namespace

Win32Window::Win32Window() {
  reference_ = new WindowState(this);
}

Win32Window::~Win32Window() {
  if (reference_) {
    delete reference_;
  }
  Destroy();
}

bool Win32Window::Create(const std::wstring& title,
                         const Point& origin,
                         const Size& size) {
  Destroy();

  WNDCLASS window_class = RegisterWindowClass();

  HWND window = CreateWindowEx(
      WS_EX_APPWINDOW, window_class.lpszClassName, title.c_str(),
      WS_OVERLAPPEDWINDOW | WS_VISIBLE, origin.x, origin.y, size.width,
      size.height, nullptr, nullptr, window_class.hInstance, reference_);

  return window != nullptr;
}

WNDCLASS Win32Window::RegisterWindowClass() {
  WNDCLASS window_class{};
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = kWindowClassName;
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.cbClsExtra = 0;
  window_class.cbWndExtra = 0;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hIcon =
      LoadIcon(window_class.hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
  window_class.hbrBackground = 0;
  window_class.lpszMenuName = nullptr;
  window_class.lpfnWndProc = Win32Window::WndProc;
  RegisterClass(&window_class);
  return window_class;
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                      UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_state = reinterpret_cast<WindowState*>(
        reinterpret_cast<CREATESTRUCT*>(lparam)->lpCreateParams);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_state->window));
  }

  if (g_window_proc_delegate) {
    return g_window_proc_delegate(window, message, wparam, lparam);
  }

  if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT Win32Window::MessageHandler(HWND hwnd,
                                    UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      Destroy();
      return 0;

    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;

      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top,
                   newWidth, newHeight, SWP_NOZORDER | SWP_NOACTIVATE);
      return 0;
    }
    case WM_SIZE: {
      RECT rect;
      GetClientRect(hwnd, &rect);
      if (child_content_ != nullptr) {
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      return 0;
    }

    case WM_ACTIVATE:
      if (child_content_ != nullptr) {
        SetFocus(child_content_);
      }
      return 0;

    case WM_DWMCOMPOSITIONCHANGED:
      return 0;
  }

  return DefWindowProc(hwnd, message, wparam, lparam);
}

void Win32Window::Destroy() {
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  if (g_window_proc_delegate) {
    g_window_proc_delegate = nullptr;
  }
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame;
  GetClientRect(window_handle_, &frame);
  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);
  SetFocus(child_content_);
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() {
  return true;
}

void Win32Window::OnDestroy() {}

void Win32Window::Show() {
  ShowWindow(window_handle_, SW_SHOW);
  UpdateWindow(window_handle_);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}
