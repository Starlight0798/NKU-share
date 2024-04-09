include_directories(.)

add_executable(
  main

  main.cpp
)
target_link_libraries(
  main

  snark
)
target_include_directories(
  main

  PUBLIC
  ${DEPENDS_DIR}/libsnark
  ${DEPENDS_DIR}/libsnark/depends/libfqfft
)

add_executable(
  test

  test.cpp
)
target_link_libraries(
  test

  snark
)
target_include_directories(
  test

  PUBLIC
  ${DEPENDS_DIR}/libsnark
  ${DEPENDS_DIR}/libsnark/depends/libfqfft
)

add_executable(
  range

  range.cpp
)
target_link_libraries(
  range

  snark
)
target_include_directories(
  range

  PUBLIC
  ${DEPENDS_DIR}/libsnark
  ${DEPENDS_DIR}/libsnark/depends/libfqfft
)

add_executable(
 mysetup
 mysetup.cpp
)
target_link_libraries(
 mysetup
 snark
)
target_include_directories(
 mysetup
 PUBLIC
 ${DEPENDS_DIR}/libsnark
 ${DEPENDS_DIR}/libsnark/depends/libfqfft
)
add_executable(
 myprove
 myprove.cpp
)
target_link_libraries(
 myprove
 snark
)
target_include_directories(
 myprove
 PUBLIC
 ${DEPENDS_DIR}/libsnark
 ${DEPENDS_DIR}/libsnark/depends/libfqfft
)
add_executable(
 myverify
 myverify.cpp
)
target_link_libraries(
 myverify
 snark
)
target_include_directories(
 myverify
 PUBLIC
 ${DEPENDS_DIR}/libsnark
 ${DEPENDS_DIR}/libsnark/depends/libfqfft
)
