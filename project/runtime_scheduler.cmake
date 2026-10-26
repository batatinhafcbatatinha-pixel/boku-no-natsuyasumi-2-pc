# Bounded instrumentation of the observed boot stall, in a local source copy.
set(original "${BOKU2_RUNTIME_SOURCE_DIR}/src/lib/Kernel/EeScheduler.cpp")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${original}")
file(READ "${original}" content)
set(needle "        if (checkpointDue(kGuestDispatchCycles))")
set(replacement [=[        const bool bokuCheckpoint = checkpointDue(kGuestDispatchCycles);
        if (context.pc == 0x2338dcu) {
            static uint64_t bokuSamples = 0;
            ++bokuSamples;
            if ((bokuSamples & (bokuSamples - 1u)) == 0u) {
                std::cerr << "[boku:callback-resume] samples=" << bokuSamples
                          << " checkpoint=" << bokuCheckpoint
                          << " cycle=" << m_eeCycle
                          << " deadline=" << m_nextDeadlineCycle.load()
                          << " reschedule=" << m_rescheduleRequested
                          << " depth=" << running->invocations.size()
                          << std::hex << " sp=0x" << getRegU32(&context, 29)
                          << " ra=0x" << getRegU32(&context, 31)
                          << " a0=0x" << getRegU32(&context, 4)
                          << " a1=0x" << getRegU32(&context, 5)
                          << std::dec << std::endl;
            }
        }
        if (bokuCheckpoint)]=])
string(FIND "${content}" "${needle}" found)
if(found LESS 0)
    message(FATAL_ERROR "Review Boku2 scheduler diagnostic: shared source changed")
endif()
string(REPLACE "${needle}" "${replacement}" content "${content}")
set(destination "${BOKU2_LOCAL_RUNTIME_DIR}/EeScheduler.cpp")
file(CONFIGURE OUTPUT "${destination}" CONTENT "${content}" @ONLY)
get_target_property(sources ps2_runtime SOURCES)
list(REMOVE_ITEM sources "src/lib/Kernel/EeScheduler.cpp" "${original}")
list(APPEND sources "${destination}")
set_property(TARGET ps2_runtime PROPERTY SOURCES ${sources})
set_source_files_properties("${destination}" TARGET_DIRECTORY ps2_runtime PROPERTIES
    INCLUDE_DIRECTORIES "${BOKU2_RUNTIME_SOURCE_DIR}/src/lib/Kernel")
