string(REPLACE "\"" "" StringModules ${StringModules})
string(REPLACE " " ";" ListModules ${StringModules})

if( ${Slicer_Revision} GREATER 0 )
  set( get_revision "-r ${Slicer_Revision}" )
endif()
#downloads CLI modules
foreach( var ${ListModules} )
  execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} export https://github.com/Slicer/Slicer/trunk/Modules/CLI/${var} ${DOWNLOAD_DIR}/Modules/CLI/${var} --force ${get_revision} )
  file(READ ${DOWNLOAD_DIR}/Modules/CLI/${var}/CMakeLists.txt CMakeLists)
  string(REPLACE "LOGO_HEADER" "EXECUTABLE_ONLY LOGO_HEADER" CMakeListsModified ${CMakeLists} )
  file(WRITE ${DOWNLOAD_DIR}/Modules/CLI/${var}/CMakeLists.txt ${CMakeListsModified} )
endforeach()
#downloads resources (icons...)
execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} export https://github.com/Slicer/Slicer/trunk/Resources ${DOWNLOAD_DIR}/Resources --force ${get_revision} )
#downloads necessary libraries
execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} export https://github.com/Slicer/Slicer/trunk/Libs/ITKFactoryRegistration ${DOWNLOAD_DIR}/Libs/ITKFactoryRegistration --force ${get_revision} )
execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} export https://github.com/Slicer/Slicer/trunk/Base/CLI ${DOWNLOAD_DIR}/Base/CLI --force ${get_revision} )
#download test data
execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} export https://github.com/Slicer/Slicer/trunk/Testing/Data/Input ${DOWNLOAD_DIR}/Testing/Data/Input --force ${get_revision} )
execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} export https://github.com/Slicer/Slicer/trunk/Libs/MRML/Core/Testing/TestData ${DOWNLOAD_DIR}/Libs/MRML/Core/Testing/TestData --force ${get_revision} )
#modify ITKFactoryRegistration CMakeLists to build that library statically
file(READ ${DOWNLOAD_DIR}/Libs/ITKFactoryRegistration/CMakeLists.txt FactoryCMakeLists)
string(REPLACE "SHARED" "STATIC" FactoryCMakeListsModified ${FactoryCMakeLists} )
file(WRITE ${DOWNLOAD_DIR}/Libs/ITKFactoryRegistration/CMakeLists.txt ${FactoryCMakeListsModified})
