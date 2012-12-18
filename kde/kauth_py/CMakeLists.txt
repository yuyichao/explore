project(kde.kauth_py)
find_package(KDE4 REQUIRED)
include(KDE4Defaults)
include_directories(${KDE4_INCLUDES})

kde4_install_auth_actions(org.yyc.arch.kauthpy org.yyc.arch.kauthpy.action)

install(FILES main.py DESTINATION bin
  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
  GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
  RENAME pykauth)

install(FILES helper.py DESTINATION "${LIBEXEC_INSTALL_DIR}"
  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
  GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
  RENAME pykauth_helper)

kde4_install_auth_helper_files(pykauth_helper
  org.yyc.arch.kauthpy root)
