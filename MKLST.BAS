DIM Ch AS Byte
DIM FileName AS STRING
SCREEN 0
COLOR 11, 1
CLS
PRINT
PRINT
PRINT
PRINT
PRINT
PRINT "                             MKLST Utility Program "
PRINT "                    ----------------------------------------                   "
PRINT "                    MkLst is a program to create an empty"
PRINT "                    device file, which is assigned with"
PRINT "                    NDP Printer device."
PRINT "                    When you overwrite an existing file "
PRINT "                    the contents is destroyed."
PRINT
PRINT "                    Enter file name without extension
PRINT "                    to create or press <Enter> to exit:"
INPUT FileName
IF FileName<>"" THEN
  LET FileName=FileName+".LST"
        OPEN FileName FOR OUTPUT ACCESS WRITE AS #1
        PRINT #1,
  CLOSE #1
  PRINT "                     File ";FileName;" created"
  PRINT
ELSE
  PRINT "                    Nothing changed..."
  PRINT
END IF
PRINT "Press any key to exit"
INPUT Ch
CLS
END
