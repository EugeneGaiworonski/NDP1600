(*{$DEFINE FP}*)
{$IFDEF FP}{$ASMMODE INTEL}{$MODE TP}{$CODEPAGE CP866}{$ENDIF}
{
                      --
                     / /
      --\  --   ----/ / /---\    N E U M A N N
     /  | / / / --\  / / --\ \
    / / |/ / / /  / / / /  / /   D A T A
   / /| / / / /  / / / /  / /
  / / |  /  \ \-- / /  \-/ /     P R O C E S S O R
  --  \--    \---/ / /----
                  / /
                  --

NPROCESS.PAS
DESCRIPTION
  Processor & memory unit.
  NDP-1600 educational computer model.
  By Eugene Gaiworonski
  e.gaiworonski@sochi.com
  Nov 2023, Feb 2024
AUTHOR
  Eugene Gaiworonski
  e.gaiworonski@sochi.com
  https://github.com/EugeneGaiworonski
LICENSE
  Hereby Public Domain
  Use this code as you see fit. By using or compiling this code or derivative
  thereof, you are consenting to the hold the author, E. Gaiworonski, harmless
  for all effects or side-effects its use. This code works great for me,
  but you are using it at your own risk.
}

UNIT NProcess;
INTERFACE
USES WinCrt, NDevMgr, NLibrary;
CONST
  MemSize=16;
  LogFileName: String='NDP1600.LOG';
  InputFileLength=32; { 32 bytes = 16 words x 16 bit }
TYPE
  TAddress=0..MemSize-1;
  TWord=Integer;
  TMemory=ARRAY[0..MemSize-1] OF TWord;
  TSystem=OBJECT
    PUBLIC
       Mem: TMemory;
     ACReg: TWord; { Accumulator register }
     A1Reg: TWord; { 1st argument register }
     A2Reg: TWord; { 2nd argument register }
     IPReg: Byte;  { Instruction pointer register }
    SubReg: Byte;  { Subroutine register }
     CIReg: TWord; { Current instruction register }
     ERReg: Byte;  { Error register }
     OmReg: 0..2;  { Omega register 0 - res=0, 1 - res<0, 2 - res>0 }
      SReg: 0..1;  { Subroutine register 0 - main, 1 - subroutine }
    ExCode: Byte;  { Executed instruction code}
    PROCEDURE Initiate;
    PROCEDURE ExecuteInstruction;
  END;
VAR
  Proc: TSystem;
IMPLEMENTATION
PROCEDURE TSystem.Initiate;
  VAR Idx: Byte;
  BEGIN
    FOR Idx:=0 TO MemSize-1 DO Mem[Idx]:=0;
    ACReg:=0; A1Reg:=0; A2Reg:=0; IPReg:=0;
    CIReg:=0; ERReg:=0; OmReg:=0; IPReg:=0;
    SubReg:=0; Sreg:=0; ExCode:=0;
  END { TSystem.Initiate };
PROCEDURE TSystem.ExecuteInstruction;
  BEGIN
    ERReg:=0;
    CIReg:=Mem[IPReg];
    Inc(IPReg);
    IF IPReg>=MemSize THEN IPReg:=0;
    A1Reg:=Mem[GetLo(Hi(CIReg))];
    A2Reg:=Mem[GetHi(Lo(CIReg))];
    ExCode:=GetHi(Hi(CIReg));
    CASE ExCode OF
    $00: BEGIN { NOOP (COPY (1):=(1)) }
           ACReg:=A1Reg;
           Mem[GetLo(Hi(CIReg))]:=ACReg;
         END;
    $01: BEGIN { COPY (3):=(1) }
           ACReg:=A1Reg;
           Mem[GetLo(Lo(CIReg))]:=ACReg;
         END;
    $02: BEGIN { IADD (3):=(1)+(2) }
           ACReg:=A1Reg+A2Reg;
           ASM
                        JNO @NoOverFlow
	                      MOV BYTE PTR [ERReg], 2
	                      JMP @Done;
           @NoOverFlow: MOV BYTE PTR [ERReg], 0
           @Done:
           END;
         END;
    $03: BEGIN { ISUB (3):=(1)-(2) }
           ACReg:=A1Reg-A2Reg;
           ASM
                        JNO @NoOverFlow
                        MOV BYTE PTR [ERReg], 2
                        JMP @Done;
           @NoOverFlow: MOV BYTE PTR [ERReg], 0
           @Done:
           END;
         END;
    $04: BEGIN { IMPY (3):=(1)*(2) }
           ACReg:=A1Reg*A2Reg;
           ASM
                        JNO @NoOverFlow
	                      MOV BYTE PTR [ERReg], 2
	                      JMP @Done;
           @NoOverFlow: MOV BYTE PTR [ERReg], 0
           @Done:
           END;
         END;
    $05: BEGIN { IDIV (3):=(1)DIV(2) }
           ACReg:=A1Reg DIV A2Reg;
           ASM
                        JNO @NoOverFlow
	                      MOV BYTE PTR [ERReg], 2
	                      JMP @Done;
           @NoOverFlow: MOV BYTE PTR [ERReg], 0
           @Done:
           END;
         END;
    $06: BEGIN { IMOD (3):=(1)MOD(2) }
           ACReg:=A1Reg MOD A2Reg;
           ASM
                        JNO @NoOverFlow
	                      MOV BYTE PTR [ERReg], 2
	                      JMP @Done;
           @NoOverFlow: MOV BYTE PTR [ERReg], 0
           @Done:
           END;
         END;
    $07: BEGIN { TRA IPReg:=3 }
           IPReg:=GetLo(Lo(CIReg));
         END;
    $08: BEGIN { TRC W=0->IPReg:=1|W=1->IPReg:=2|W=2->IPReg:=3 }
           CASE OmReg OF
             0: IPReg:=GetLo(Hi(CIReg));
             1: IPReg:=GetHi(Lo(CIReg));
             2: IPReg:=GetLo(Lo(CIReg));
           END;
         END;
    $09: BEGIN { TRAS SReg=0->SubReg:=IPReg,IPReg:=3,SReg:=1 }
           IF SReg=0 THEN BEGIN
             SubReg:=IPReg;
             SReg:=1;
             IPReg:=GetLo(Lo(CIReg));
           END
           ELSE ERReg:=3;
         END;
    $0A: BEGIN { TRCS W=0->SReg=0->SubReg:=IPReg,IPReg:=1
                |W=1->SReg=0->SubReg:=IPReg,IPReg:=2
                |W=2->SReg=0->SubReg:=IPReg,IPReg:=3 }
           IF SReg=0 THEN BEGIN
             SubReg:=IPReg;
             SReg:=1;
             CASE OmReg OF
               0: IPReg:=GetLo(Hi(CIReg));
               1: IPReg:=GetHi(Lo(CIReg));
               2: IPReg:=GetLo(Lo(CIReg));
             END;
           END
           ELSE ERReg:=3;
         END;
    $0B: BEGIN { RETS SReg=1->IPReg:=SubReg,SReg:=0 }
           IF SReg=1 THEN BEGIN
             IPREG:=SubReg;
             SReg:=0;
           END
           ELSE ERReg:=4;
         END;
    $0C: BEGIN { RST OmReg:=0, ERReg:=0 }
           OmReg:=0; ERReg:=0;
         END;
    $0D: BEGIN { READ Device 1, Qty 2, Addr 3 }
           Dev.Input(GetLo(Hi(CIReg)), GetHi(Lo(CIReg)), GetLo(Lo(CIReg)));
           ERReg:=Dev.IOErr;
         END;
    $0E: BEGIN { WRITE Device 1, Qty 2, Addr 3 }
           Dev.Output(GetLo(Hi(CIReg)), GetHi(Lo(CIReg)), GetLo(Lo(CIReg)));
           ERReg:=Dev.IOErr;
         END;
    $0F: BEGIN { STOP }
           OmReg:=0; ERReg:=5;
         END;
    ELSE
      ERReg:=1; { Illegal Instruction}
    END;
  END { TSystem.ExecuteInstruction };
END { SysProc }.
