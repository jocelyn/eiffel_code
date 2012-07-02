setlocal
set TMP_PATCH=%~dp0suggestive.patch
cd %EIFFEL_SRC%
 
svn diff framework\vision2\suggestive_typing > %TMP_PATCH%
endlocal
