enable_language(C)
enable_language(CXX)

include(${CMAKE_CURRENT_LIST_DIR}/Common.cmake)

#-----------------------------------------------------------------------------
find_package(SlicerExecutionModel NO_MODULE REQUIRED GenerateCLP)
include(${GenerateCLP_USE_FILE})
include(${SlicerExecutionModel_USE_FILE})

#-----------------------------------------------------------------------------
set(expected_ITK_VERSION_MAJOR ${ITK_VERSION_MAJOR})
find_package(ITK NO_MODULE REQUIRED)
if(${ITK_VERSION_MAJOR} VERSION_LESS ${expected_ITK_VERSION_MAJOR})
  # Note: Since ITKv3 doesn't include a ITKConfigVersion.cmake file, let's check the version
  #       explicitly instead of passing the version as an argument to find_package() command.
  message(FATAL_ERROR "Could not find a configuration file for package \"ITK\" that is compatible "
                      "with requested version \"${expected_ITK_VERSION_MAJOR}\".\n"
                      "The following configuration files were considered but not accepted:\n"
                      "  ${ITK_CONFIG}, version: ${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}.${ITK_VERSION_PATCH}\n")
endif()

include(${ITK_USE_FILE})

#-----------------------------------------------------------------------------
find_package(VTK NO_MODULE REQUIRED)
include(${VTK_USE_FILE})

option(BUILD_TESTING "Build Testing" ON)
if( BUILD_TESTING )
  enable_testing()
  include(CTest)
  set(BASELINE "${CMAKE_CURRENT_SOURCE_DIR}/Testing/Data/Baseline/CLI")
  set(TEST_DATA "${CMAKE_CURRENT_SOURCE_DIR}/Testing/Data/Input")
  set(MRML_TEST_DATA "${CMAKE_CURRENT_SOURCE_DIR}/Libs/MRML/Core/Testing/TestData")
  set(TEMP "${CMAKE_CURRENT_BINARY_DIR}/Testing/Temporary")
endif()
#-----------------------------------------------------------------------------
# set SlicerExecutionModel install variables
#-----------------------------------------------------------------------------

set( SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION bin )
set( SlicerExecutionModel_DEFAULT_CLI_INSTALL_ARCHIVE_DESTINATION lib/archive )
set( SlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION lib )
set( Slicer_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR} )#Where the logo are downloaded
set( Slicer_INSTALL_CLIMODULES_SHARE_DIR ${SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION} )
set( Slicer_INSTALL_CLIMODULES_BIN_DIR ${SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION} )
set( Slicer_INSTALL_CLIMODULES_LIB_DIR ${SlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION} )
set( Slicer_CLIMODULES_LIB_DIR lib )
set( Slicer_CLIMODULES_BIN_DIR bin )
set( Slicer_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR} )
set( Slicer_INSTALL_BIN_DIR bin )
set( Slicer_INSTALL_LIB_DIR lib )


set(SlicerExecutionModel_EXTRA_EXECUTABLE_TARGET_LIBRARIES
    ${SlicerExecutionModel_EXTRA_EXECUTABLE_TARGET_LIBRARIES} ITKFactoryRegistration
    CACHE INTERNAL "SlicerExecutionModel extra executable target libraries" FORCE
    )

#-----------------------------------------------------------------------------
# Add module sub-directory if USE_<MODULENAME> is both defined and true
#-----------------------------------------------------------------------------
foreach(var ${ListModules} )
  option(BUILD_CLI_${var} "Build ${var}" OFF)
endforeach()

add_subdirectory(Libs/ITKFactoryRegistration)
add_subdirectory(Base/CLI)
link_directories(lib)
link_libraries(ITKFactoryRegistration)
#add_subdirectory(CLI)
file( GLOB ListModules RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/Modules/CLI/ Modules/CLI/* )
list( SORT ListModules )
foreach( var ${ListModules} )
  set( ${var}_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Modules/CLI/${var} )
  if( BUILD_CLI_${var} )
    add_subdirectory( Modules/CLI/${var} )
  endif()
endforeach()
