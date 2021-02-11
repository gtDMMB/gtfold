## Running of unit tests configuration:
function(Func_runUnitTest InputSeqFamily UnitTestName)
     message("\n   >> Running UNIT TEST: GTFoldUnitTest-${InputSeqFamily}-${UnitTestName}")
     execute_process(
          COMMAND bash -c "./bin/gtfold-test -v ./gtfold-mfe/unit-test-data/${InputSeqFamily}/${UnitTestName}.seq"
          RESULT_VARIABLE LocalUnitTestExitCode
          OUTPUT_VARIABLE LocalUnitTestStdout
     )   
     if(LocalUnitTestExitCode EQUAL 0)  
          message("       [PASSED: OK]")
     else()
          message("       [FAILED: XX]")
          message("       TEST CASE OUTPUT:\n${LocalUnitTestStdout}\n")
     endif()
endfunction(Func_runUnitTest)

message("Running *ALL* unit tests -- NOTE: This can take a long time -- ...\n")

if(${RUN_UNIT_TESTS})
     Func_runUnitTest("16S" "K00421")
     Func_runUnitTest("16S" "X00794")
     Func_runUnitTest("16S" "X52949")
     Func_runUnitTest("16S" "X54252")
     Func_runUnitTest("16S" "X54253")
     Func_runUnitTest("16S" "X54604")
     Func_runUnitTest("16S" "X65063")
     Func_runUnitTest("16S" "X98467")
     Func_runUnitTest("16S" "Y00266")
     Func_runUnitTest("16S" "Z17210")
     Func_runUnitTest("16S" "Z17224")
     Func_runUnitTest("23S" "J01527")
     Func_runUnitTest("23S" "K01868")
     Func_runUnitTest("23S" "M67497")
     Func_runUnitTest("23S" "X14386")
     Func_runUnitTest("23S" "X52392")
     Func_runUnitTest("23S" "X52949")
     Func_runUnitTest("23S" "X53361")
     Func_runUnitTest("23S" "X54252")
endif()
