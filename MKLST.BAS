DIM OldTextAttr AS BYTE
DIM FileName AS STRING
SCREEN 0
COLOR 1,14
CLS
PRINT "MkLst is a program to manage (create) empty device file, which is assigned with NDP Printer device"
PRINT "When you overwrite an existing file the contents is destroyed"
PRINT "Enter file name without extension to create or press <Enter> to exit:"
INPUT FileName
IF FileName<>"" THEN
  LET FileName=FileName+".LST"
        OPEN FileName FOR OUTPUT ACCESS WRITE AS #1
        PRINT #1, "" 'CHR$(10)+CHR$(13)
  CLOSE #1
  PRINT "File ", FileName," created"
ELSE
  PRINT "Nothing changed"
END IF
PRINT
PRINT "Press any key to exit"
END