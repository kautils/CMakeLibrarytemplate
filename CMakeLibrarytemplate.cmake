macro(CMakeLibraryTemplate parse_prfx)
    
    macro(unsetter list)
        foreach(__var ${list})
            unset(${__var})
        endforeach()
        unset(__var)
    endmacro()
    
    macro(debug_print_vars list)
        if( ${parse_prfx}_DEBUG_VERBOSE)
            include(CMakePrintHelpers)
            foreach(__var ${list})
                cmake_print_variables(${__var})
            endforeach()
            message(WARNING ${parse_prfx}_DEBUG_VERBOSE)
            unset(__var)
        endif()
    endmacro()
    
    set(__unset_vars)
    cmake_parse_arguments( ${parse_prfx} "DEBUG_VERBOSE" "MODULE_NAME;EXPORT_NAME_PREFIX;EXPORT_VERSION;EXPORT_VERSION_COMPATIBILITY;EXPORT_CONFIG_IN_FILE;EXPORT_LIB_TYPE;DESTINATION_LIB_DIR" "MODULE_PREFIX;LINK_LIBS;DESTINATION_INCLUDE_DIR;DESTINATION_CMAKE_DIR;SOURCES;INCLUDES" ${ARGV})
    
    list(APPEND __unset_vars __prfx_main __prfx_alias __PRFX_MAIN)
    foreach(prfx ${${parse_prfx}_MODULE_PREFIX})
        string(APPEND __prfx_main ${prfx}_)
        string(APPEND __prfx_alias ${prfx}::)
    endforeach()
    string(TOUPPER ${__prfx_main} __PRFX_MAIN)
    
    list(APPEND __unset_vars __lib_type __LIB_TYPE)
        string(TOLOWER ${${parse_prfx}_EXPORT_LIB_TYPE} __lib_type)
        string(TOUPPER ${${parse_prfx}_EXPORT_LIB_TYPE} __LIB_TYPE)
    
    list(APPEND __unset_vars __module __MODULE)
        set(__module ${${parse_prfx}_MODULE_NAME})
        string(TOUPPER ${__module} __MODULE)
    
    list(APPEND __unset_vars __exp_compat __exp_name __exp_ver __exp_config_in)
        set(__exp_name  ${${parse_prfx}_EXPORT_NAME_PREFIX}.${__lib_type})
        set(__exp_ver ${${parse_prfx}_EXPORT_VERSION})
        set(__exp_config_in ${${parse_prfx}_EXPORT_CONFIG_IN_FILE})
        set(__exp_compat ${${parse_prfx}_EXPORT_VERSION_COMPATIBILITY})
    
    
    list(APPEND __unset_vars __srcs __includes __libs)
        set(__includes ${${parse_prfx}_INCLUDES})
        set(__libs ${${parse_prfx}_LINK_LIBS})
        set(__srcs ${${parse_prfx}_SOURCES})
    
    
    list(APPEND __unset_vars __destination_include_dirs __destination_cmake_dirs __destination_lib_dir)
        set(__destination_include_dirs ${${parse_prfx}_DESTINATION_INCLUDE_DIR})
        set(__destination_cmake_dirs ${${parse_prfx}_DESTINATION_CMAKE_DIR})
        set(__destination_lib_dir ${${parse_prfx}_DESTINATION_LIB_DIR})
    
    list(APPEND __unset_vars __main __alias) 
        set(__main ${__prfx_main}${__module}_${__exp_ver}_${__lib_type})
        set(__alias ${__prfx_alias}${__module}::${__exp_ver}::${__lib_type})
    
    
    debug_print_vars("${__unset_vars}")
    
    set(__t ${__main})
    set(${parse_prfx}_${__lib_type} ${__t})
    set(${parse_prfx}_${__lib_type}_tmain_ppcs TMAIN_${__PRFX_MAIN}${__MODULE}_${__LIB_TYPE})
    set(${parse_prfx}_${__lib_type}_tmain tmain_${__prfx_main}${__module}_${__lib_type})
    
    add_library(${__t} ${__LIB_TYPE})
    add_library(${__alias} ALIAS ${__t})
    target_sources(${__t} PRIVATE ${__srcs})
    target_link_libraries(${__t} PRIVATE ${__libs})
    target_include_directories(${__t} PUBLIC ${__includes})
    set_target_properties(${__t} PROPERTIES OUTPUT_NAME  ${__prfx_main}${__module})
    
    ##### INSTALL & EXPORT #####
    # install files
    file(GLOB headers ${CMAKE_CURRENT_LIST_DIR}/*.h)
    foreach(include_dest ${__destination_include_dirs})
        install(FILES ${headers} DESTINATION ${include_dest}/${__module}) 
    endforeach()
    
    foreach(include_dest ${__destination_cmake_dirs})
        install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}Config.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}ConfigVersion.cmake
            DESTINATION ${__destination_lib_dir}/${include_dest}/${__exp_name}
        )
    endforeach()
    
    # cmake for find package
    install(TARGETS ${__t} EXPORT ${__t} DESTINATION ${__destination_lib_dir}) 
    set_target_properties(${__t} PROPERTIES EXPORT_NAME ${__alias} ) 
    install(EXPORT ${__t} FILE ${__exp_name}.cmake DESTINATION ${__destination_lib_dir}/cmake/${__exp_name})
    export(EXPORT ${__t} FILE "${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}.cmake")
    
    
    list(APPEND __unset_vars __config_in_content __exp_config_in)
    if(NOT EXISTS ${__exp_config_in})
        if(NOT DEFINED __exp_config_in)
            set(__exp_config_in "${CMAKE_CURRENT_LIST_DIR}/${__module}.${__lib_type}.config.cmake.in")
        endif()
        string(APPEND __config_in_content
                set(@PROJECT_NAME@_VERSION @PROJECT_VERSION@) 
                \n @PACKAGE_INIT@
                \n set(@PROJECT_NAME@_DIR "\${CMAKE_CURRENT_LIST_DIR}") 
                \n set(@PROJECT_NAME@_SYSCONFIG_DIR "\${CMAKE_CURRENT_LIST_DIR}")
                \n include(\${CMAKE_CURRENT_LIST_DIR}/@PROJECT_NAME@.${__lib_type}.cmake)
                \n check_required_components(@PROJECT_NAME@)
                )
        file(WRITE "${__exp_config_in}" ${__config_in_content})
    endif()
    
    include(CMakePackageConfigHelpers)
    foreach(include_dest ${__destination_cmake_dirs})
        # Config.cmake
        configure_package_config_file( 
          "${__exp_config_in}"
          "${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}Config.cmake"
          INSTALL_DESTINATION "${__destination_lib_dir}/${include_dest}/${__exp_name}"
        )
    endforeach()
        
    # ConfigVersion.cmake
    write_basic_package_version_file( 
      "${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}ConfigVersion.cmake"
      VERSION "${__exp_ver}" 
      COMPATIBILITY ${__exp_compat}
    )
    
    unsetter("${__unset_vars}")
    
endmacro()