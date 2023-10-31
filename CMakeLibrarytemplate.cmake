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
    cmake_parse_arguments( ${parse_prfx} 
            "DEBUG_VERBOSE" 
            "MODULE_NAME;EXPORT_NAME_PREFIX;EXPORT_VERSION;EXPORT_VERSION_COMPATIBILITY;EXPORT_NAME_CMAKE_DIR;EXPORT_CONFIG_IN_FILE;EXPORT_CONFIG_IN_ADDITIONAL_CONTENT_AFTER;EXPORT_CONFIG_IN_ADDITIONAL_CONTENT_BEFORE;EXPORT_LIB_TYPE;DESTINATION_LIB_DIR;EXPORT_NAME_SUFFIX;EXPORT_RENAME" 
            "MODULE_PREFIX;LINK_LIBS;DESTINATION_INCLUDE_DIR;DESTINATION_CMAKE_DIR;SOURCES;INCLUDES" 
            ${ARGV})
    
    list(APPEND __unset_vars ${parse_prfx}_DEBUG_VERBOSE 
            ${parse_prfx}_MODULE_NAME 
            ${parse_prfx}_EXPORT_NAME_PREFIX 
            ${parse_prfx}_EXPORT_NAME_SUFFIX 
            ${parse_prfx}_EXPORT_RENAME 
            ${parse_prfx}_EXPORT_NAME_CMAKE_DIR 
            ${parse_prfx}_EXPORT_VERSION ${parse_prfx}_EXPORT_VERSION_COMPATIBILITY ${parse_prfx}_EXPORT_CONFIG_IN_FILE ${parse_prfx}_EXPORT_CONFIG_IN_ADDITIONAL_CONTENT_AFTER ${parse_prfx}_EXPORT_CONFIG_IN_ADDITIONAL_CONTENT_BEFORE ${parse_prfx}_EXPORT_LIB_TYPE 
            ${parse_prfx}_DESTINATION_LIB_DIR ${parse_prfx}_DESTINATION_CMAKE_DIR ${parse_prfx}_DESTINATION_INCLUDE_DIR
            ${parse_prfx}_MODULE_PREFIX ${parse_prfx}_LINK_LIBS  
            ${parse_prfx}_SOURCES ${parse_prfx}_INCLUDES )
    
    
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
    
    list(APPEND __unset_vars __exp_compat ${m}_exp_real_version ${m}_exp_dummy_version __exp_config_in __exp_config_in_additional_after __exp_config_in_additional_before)
        set(${m}_exp_real_version ${${parse_prfx}_EXPORT_VERSION})
        set(__exp_compat ${${parse_prfx}_EXPORT_VERSION_COMPATIBILITY})
        set(__exp_config_in ${${parse_prfx}_EXPORT_CONFIG_IN_FILE})
        string(APPEND __exp_config_in_additional_after "${${parse_prfx}_EXPORT_CONFIG_IN_ADDITIONAL_CONTENT_AFTER}")
        string(APPEND __exp_config_in_additional_before "${${parse_prfx}_EXPORT_CONFIG_IN_ADDITIONAL_CONTENT_BEFORE}")
    
    
    # priority EXPORT_RENAME > EXPORT_NAME_SUFFIX > default 
    list(APPEND __unset_vars __main __alias __exp_name ${m}_output_name) 
    if(NOT "${${parse_prfx}_EXPORT_RENAME}" STREQUAL "") # case EXPORT_RENAME is specified
        set(${m}_exp_dummy_version ${${parse_prfx}_EXPORT_VERSION})
        set(__main ${${parse_prfx}_EXPORT_RENAME}_target)
        set(__alias ${${parse_prfx}_EXPORT_RENAME})
        set(__exp_name  ${${parse_prfx}_EXPORT_RENAME})
        set(${m}_output_name ${${parse_prfx}_EXPORT_RENAME})
    else()
        if(NOT "${${parse_prfx}_EXPORT_NAME_SUFFIX}" STREQUAL "") # case EXPORT_NAME_SUFFIX is specified
            set(${m}_exp_dummy_version "${${parse_prfx}_EXPORT_NAME_SUFFIX}")
        else() # case default
            set(${m}_exp_dummy_version "${${m}_exp_real_version}")
        endif()
        
        set(__main ${__prfx_main}${__module}_${${m}_exp_dummy_version}_${__lib_type})
        set(__alias ${__prfx_alias}${__module}::${${m}_exp_dummy_version}::${__lib_type})
        set(__exp_name  ${${parse_prfx}_EXPORT_NAME_PREFIX}.${__lib_type})
        set(${m}_output_name ${__prfx_main}${__module}.${${m}_exp_dummy_version})
    endif()
    
    if(DEFINED ${parse_prfx}_EXPORT_NAME_CMAKE_DIR)
        set(__exp_name_cmake_dir ${${parse_prfx}_EXPORT_NAME_CMAKE_DIR})
    else()
        set(__exp_name_cmake_dir ${${parse_prfx}_EXPORT_NAME_PREFIX})
    endif()
    

    list(APPEND __unset_vars __srcs __includes __libs)
        set(__includes ${${parse_prfx}_INCLUDES})
        set(__libs ${${parse_prfx}_LINK_LIBS})
        set(__srcs ${${parse_prfx}_SOURCES})
    
    list(APPEND __unset_vars __destination_include_dirs __destination_cmake_dirs __destination_lib_dir)
        set(__destination_include_dirs ${${parse_prfx}_DESTINATION_INCLUDE_DIR})
        set(__destination_cmake_dirs ${${parse_prfx}_DESTINATION_CMAKE_DIR})
        set(__destination_lib_dir ${${parse_prfx}_DESTINATION_LIB_DIR})
    
    debug_print_vars("${__unset_vars}")
    
    set(__t ${__main})
    set(${parse_prfx}_${__lib_type} ${__t})
    set(${parse_prfx}_${__lib_type}_tmain_ppcs TMAIN_${__PRFX_MAIN}${__MODULE}_${__LIB_TYPE})
    set(${parse_prfx}_${__lib_type}_tmain tmain_${__prfx_main}${__module}_${${m}_exp_dummy_version}_${__lib_type})
    
    add_library(${__t} ${__LIB_TYPE})
    add_library(${__alias} ALIAS ${__t})
    target_sources(${__t} PRIVATE ${__srcs})
    
    
    macro(split_interface __private __build __install __list)
        foreach(__var ${__list})
            string(FIND ${__var} $<BUILD_ __pos)
            if(${__pos} EQUAL 0)
                list(APPEND ${__build} ${__var})
                continue()
            endif()
            
            string(FIND ${__var} $<INSTALL_ __pos)
            if(${__pos} EQUAL 0)
                list(APPEND ${__install} ${__var})
                continue()
            endif()
            
            list(APPEND ${__private} ${__var})
        endforeach()
        unset(__build)
        unset(__install)
        unset(__list)
        unset(__pos)
    endmacro()
    
    list(APPEND __unset_vars __lib_bld_private __inc_bld_private __inc_bld_intfc __inc_ins_intfc __lib_bld_intfc __lib_ins_intfc)
    split_interface(__inc_bld_private __inc_bld_intfc __inc_ins_intfc "${__includes}")
    split_interface(__lib_bld_private __lib_bld_intfc __lib_ins_intfc "${__libs}")
    
    
    if(NOT ${__lib_type} STREQUAL "interface") # shared or static library
        # private
        target_link_libraries(${__t} PRIVATE ${__lib_bld_private})
        target_include_directories(${__t} PRIVATE ${__inc_bld_private})
        
        # build interface (find_package)
        target_link_libraries(${__t} INTERFACE ${__lib_bld_intfc})
        target_include_directories(${__t} INTERFACE ${__inc_bld_intfc})
        
        # install interface 
        target_include_directories(${__t} PUBLIC ${__lib_ins_intfc})
        target_include_directories(${__t} PUBLIC ${__inc_ins_intfc})
    else() # interafce library
        # interface
        target_link_libraries(${__t} INTERFACE ${__lib_bld_private})
        target_include_directories(${__t} INTERFACE ${__inc_bld_private})
        
        # build interface (find_package)
        target_link_libraries(${__t} INTERFACE ${__lib_bld_intfc})
        target_include_directories(${__t} INTERFACE ${__inc_bld_intfc})
        
        # install interface 
        target_include_directories(${__t} INTERFACE ${__lib_ins_intfc})
        target_include_directories(${__t} INTERFACE ${__inc_ins_intfc})
    endif()
    
    set_target_properties(${__t} PROPERTIES OUTPUT_NAME  ${${m}_output_name})
    

    # cmake for find package
    install(TARGETS ${__t} EXPORT ${__t} DESTINATION ${__destination_lib_dir}) 
    set_target_properties(${__t} PROPERTIES EXPORT_NAME ${__alias} ) 

    
    export(EXPORT ${__t} FILE "${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}.cmake")


    ##### INSTALL & EXPORT #####
    # install files
    foreach(__include_dir ${__inc_bld_private})
        file(GLOB headers ${__include_dir}/*.h)
        foreach(include_dest ${__destination_include_dirs})
            install(FILES ${headers} DESTINATION ${include_dest}/${__module}) 
        endforeach()
    endforeach()
    
    foreach(cmake_dest ${__destination_cmake_dirs})
        # install exported target. if replace EXPORT with FILES, then ${__exp_name}.cmake which is generated in build-dir is installed. this should be cause error  
        install(EXPORT ${__t} FILE ${__exp_name}.cmake DESTINATION ${__destination_lib_dir}/cmake/${__exp_name_cmake_dir}) 
        install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}Config.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/${__exp_name}ConfigVersion.cmake
            DESTINATION ${__destination_lib_dir}/${cmake_dest}/${__exp_name_cmake_dir}
        )
    endforeach()
    
    list(APPEND __unset_vars __config_in_content __exp_config_in __config_in_content_digest)
    if(NOT DEFINED __exp_config_in)
        set(__exp_config_in "${CMAKE_CURRENT_BINARY_DIR}/${__module}.${__lib_type}.config.cmake.in")
    endif()

    string(APPEND __config_in_content
            "${__exp_config_in_additional_before}"
            \n set(${__exp_name}_VERSION @PROJECT_VERSION@) 
            \n @PACKAGE_INIT@
            \n "set(${__exp_name}_DIR \"\${CMAKE_CURRENT_LIST_DIR}\")" 
            \n "set(${__exp_name}_SYSCONFIG_DIR \"\${CMAKE_CURRENT_LIST_DIR}\")"
            \n "include(\"\${CMAKE_CURRENT_LIST_DIR}/${__exp_name}.cmake\")"
            \n "check_required_components(${__exp_name})"
            \n "${__exp_config_in_additional_after}"
            )
    string(MD5 __config_in_content_digest ${__config_in_content})
    if(NOT EXISTS ${__exp_config_in} OR (NOT "${${__exp_name}.last_content_configure_in}" STREQUAL "${__config_in_content_digest}"))
        file(WRITE "${__exp_config_in}" ${__config_in_content})
        set(${__exp_name}.last_content_configure_in ${__config_in_content_digest} CACHE STRING "" FORCE)
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
      VERSION "${${m}_exp_real_version}" 
      COMPATIBILITY ${__exp_compat}
    )
    
    unsetter("${__unset_vars}")
    
    
endmacro()