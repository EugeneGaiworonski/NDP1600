USES Crt, Dos;
CONST
  ON=1;
  OFF=0;

TYPE
  TWord=Integer;
  TTypeWriter=OBJECT
    State: OFF..ON;
    CaretPos: 1..61;
    Buffer: String[60];
    PROCEDURE PrintWord(Value: TWord);
    FUNCTION ReadWord: Tword;
  END;

VAR
  Value: TWord;
  TypeWriter: TTypeWriter;

PROCEDURE TTypeWriter.PrintWord(Value: TWord);
  VAR Idx: Integer;
  BEGIN
    Str(Value, Buffer);
           IF Value >=0 THEN
             FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer
           ELSE BEGIN
             Delete(Buffer,1,1);
             FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer;
           END;
           IF Value >= 0 THEN Buffer:='+'+Buffer ELSE Buffer:='-'+Buffer;
           Buffer:=Buffer+' ';
           FOR Idx:=1 TO Length(Buffer) DO BEGIN
             Write(Buffer[Idx]);
             Delay(20);
             Inc(CaretPos);
             IF CaretPos=61 THEN BEGIN
               WriteLn;
               CaretPos:=1;
             END;
           END;
  END { TTypeWriter.PrintWord };
FUNCTION TTypeWriter.ReadWord: TWord;
  VAR
    Convert: TWord;
    Error: Integer;
  BEGIN
    ReadLn(Buffer);
    Val(Buffer, Convert, Error);
    ReadWord:=Convert;
  END { TTypeWriter.ReadWord };

BEGIN
  ClrScr;
  Write('[^]');Value:=TypeWriter.ReadWord;
  TypeWriter.PrintWord(Value);
  Readln;
END.
