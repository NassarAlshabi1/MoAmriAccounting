//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin_c_api.h>
#include <printing/printing_plugin_c_api.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPluginCApi"));
  PrintingPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PrintingPluginCApi"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
