set(MODULE_NAME test-yash)

add_executable(${MODULE_NAME} TestYash.cpp)

find_package(Boost COMPONENTS unit_test_framework REQUIRED)
target_link_libraries(${MODULE_NAME} ${Boost_LIBRARIES} catch turtle yash)
target_include_directories(${MODULE_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
add_test(${MODULE_NAME} ${MODULE_NAME})
