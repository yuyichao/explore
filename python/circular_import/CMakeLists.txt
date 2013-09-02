add_run(test_circular_import COMMAND
  "PYTHONPATH=${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/circular_import.py")
