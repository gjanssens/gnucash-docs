#
# Functions to install the docbook xml sources for use with gnome help
#
# Paremeters:
# - docname: basename of the main xml file. Will be used to locate
#            this primary xml file and for various output files/directories
# - lang: language of the current document
# - entities: list of all xml files this document is composed of
# - figdir: name of the directory holding the images

function (add_ghelp_target docname lang entities figures)

    set(BUILD_DIR "${DATADIR_BUILD}/help/${lang}/${docname}")
    file(MAKE_DIRECTORY "${BUILD_DIR}")
    file(MAKE_DIRECTORY "${BUILD_DIR}/figures")

    set(source_files "")
    foreach(xml_file ${entities} ${docname}.xml)
        list(APPEND source_files "${CMAKE_CURRENT_SOURCE_DIR}/${xml_file}")
    endforeach()
    list(APPEND source_files "${CMAKE_SOURCE_DIR}/docbook/gnc-docbookx.dtd")

    set(dest_files "")
    foreach(xml_file ${entities} ${docname}.xml gnc-docbookx.dtd)
        list(APPEND dest_files "${BUILD_DIR}/${xml_file}")
    endforeach()

    add_custom_command(
        OUTPUT ${dest_files}
        COMMAND ${CMAKE_COMMAND} -E copy ${source_files} "${BUILD_DIR}"
        DEPENDS ${entities} "${docname}.xml" "${CMAKE_SOURCE_DIR}/docbook/gnc-docbookx.dtd"
        WORKING_DIRECTORY "${BUILD_DIR}")

    # Copy figures for this document
    file(MAKE_DIRECTORY "${BUILD_DIR}/figures")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ghelp_figtrigger"
        COMMAND ${CMAKE_COMMAND} -E copy ${figures} "${BUILD_DIR}/figures"
        COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/ghelp_figtrigger"
        DEPENDS ${figures})

    add_custom_target("${lang}-${docname}-ghelp"
        DEPENDS ${dest_files}
                "${CMAKE_CURRENT_BINARY_DIR}/ghelp_figtrigger")

    add_dependencies(${docname}-ghelp "${lang}-${docname}-ghelp")

    install(FILES ${source_files}
        DESTINATION "${CMAKE_INSTALL_DATADIR}/help/${lang}/${docname}"
        COMPONENT "ghelp")
    install(FILES ${figures}
        DESTINATION "${CMAKE_INSTALL_DATADIR}/help/${lang}/${docname}/figures"
        COMPONENT "ghelp")
endfunction()
