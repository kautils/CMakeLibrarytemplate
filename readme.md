### CMakeLibrarytemplate
* A cmake template that generates libraries which avoid version conflict during find_pacakage.

### example 
```cmake
cmake_minimum_required(VERSION 3.20)
set(__version 0.0.1)
project(SomeLibrary.${__version}
    LANGUAGES C CXX
    VERSION ${__version}
)
unset(__version)

set(module_name some_library)
set(__include_dir "${CMAKE_CURRENT_LIST_DIR}")
set(__library )

unset(srcs)
file(GLOB srcs ${CMAKE_CURRENT_LIST_DIR}/*.cc)
set(${module_name}_common_pref
    # target info
    MODULE_PREFIX a b c #  a::b::c:: is added to alias of lib
    MODULE_NAME ${module_name} 
    INCLUDES $<BUILD_INTERFACE:${__include_dir}> $<INSTALL_INTERFACE:include> # target_include_directories 
    SOURCES ${srcs} # target_sources
    LINK_LIBS ${__library}  # target_link_libraries  
    
    # export name and version
    EXPORT_NAME_PREFIX ${PROJECT_NAME} 
    EXPORT_NAME_CMAKE_DIR ${PROJECT_NAME} # output cmake files to cmake/${PROJECT_NAME}. value [EXPORT_NAME_PREFIX] is used as default.  
        
    EXPORT_VERSION ${PROJECT_VERSION}
    EXPORT_VERSION_COMPATIBILITY AnyNewerVersion
    
    # installation destination
    DESTINATION_INCLUDE_DIR include 
    DESTINATION_CMAKE_DIR cmake
    DESTINATION_LIB_DIR lib
)

CMakeLibraryTemplate(${module_name} EXPORT_LIB_TYPE static ${${module_name}_common_pref} )

# generate target for shared library. there is no confliction between static and shared. 
#CMakeLibraryTemplate(${module_name} EXPORT_LIB_TYPE shared ${${module_name}_common_pref} )

# rule
    # name for find_pacakge :  ${PROJECT_NAME}.${EXPORT_LIB_TYPE} 
    # target                :  a_b_c_${module_name}_${PROJECT_VERSION}_${EXPORT_LIB_TYPE}
    # alias                 :  a::b::c::${module_name}::${PROJECT_VERSION}::${EXPORT_LIB_TYPE}
    # preprocessor for test :  ${${module_name}_${EXPORT_LIB_TYPE}_tmain_ppcs}
# concrete
    # name for find_pacakge : SomeLibrary.0.0.1.static   
    # target                :  a_b_c_some_library_0.0.1_static
    # alias                 :  a::b::c::some_library::0.0.1::static
    # preprocessor for test :  TMAIN_A_B_C_SOME_LIBRARY_STATIC

# EXPORT_NAME_SUFFIX changes  a::b::c::${module_name}::${PROJECT_VERSION}::${EXPORT_LIB_TYPE} to a::b::c::${module_name}::[EXPORT_NAME_SUFFIX]::${EXPORT_LIB_TYPE}
# EXPORT_RENAME      changes  a::b::c::${module_name}::${PROJECT_VERSION}::${EXPORT_LIB_TYPE} to [EXPORT_RENAME] 

```