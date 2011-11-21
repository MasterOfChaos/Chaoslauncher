(******************************************************************************
 ******************************************************************************
   The RSA MD5 algorithm. Translates to Delphi with optimizations by Assarbad
   This implements RFC1321

   It follows the copyright notice of RSA Data Security Inc. 
 ******************************************************************************
 ******************************************************************************
 RSA Data Security, Inc., MD5 message-digest algorithm
 Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All rights
 reserved.

 License to copy and use this software is granted provided that it is
 identified as the "RSA Data Security, Inc. MD5 Message-Digest Algorithm" in
 all material mentioning or referencing this software or this function.
 License is also granted to make and use derivative works provided that such
 works are identified as "derived from the RSA Data Security, Inc. MD5
 Message-Digest Algorithm" in all material mentioning or referencing the
 derived work.
 RSA Data Security, Inc. makes no representations concerning either the
 merchantability of this software or the suitability of this software for any
 particular purpose. It is provided "as is" without express or implied warranty
 of any kind.
 These notices must be retained in any copies of any part of this documentation
 and/or software.
 ******************************************************************************
 ******************************************************************************


 ******************************************************************************
 ******************************************************************************
 ***                                                                        ***
 ***  Calculate MD5 hashes. Depends on the IA32 architecture.               ***
 ***                                                                        ***
 ***  Version [1.01]                                {Last mod 2005-08-15}   ***
 ***                                                                        ***
 ******************************************************************************
 ******************************************************************************

                                 _\\|//_
                                (` * * ')
 ______________________________ooO_(_)_Ooo_____________________________________
 ******************************************************************************
 ******************************************************************************
 ***                                                                        ***
 ***   Translation/optimization: Copyright (c) 2003,2005 by -=Assarbad=-    ***
 ***                                                                        ***
 ***   CONTACT TO THE AUTHOR(S):                                            ***
 ***    ____________________________________                                ***
 ***   |                                    |                               ***
 ***   | -=Assarbad=- aka Oliver            |                               ***
 ***   |____________________________________|                               ***
 ***   |                                    |                               ***
 ***   | Assarbad @ gmx.info|.net|.com|.de  |                               ***
 ***   | ICQ: 281645                        |                               ***
 ***   | AIM: nixlosheute                   |                               ***
 ***   |      nixahnungnicht                |                               ***
 ***   | MSN: Assarbad@ePost.de             |                               ***
 ***   | YIM: sherlock_holmes_and_dr_watson |                               ***
 ***   |____________________________________|                               ***
 ***             ___                                                        ***
 ***            /   |                     ||              ||                ***
 ***           / _  |   ________ ___  ____||__    ___   __||                ***
 ***          / /_\ |  / __/ __//   |/  _/|   \  /   | /   |                ***
 ***         / ___  |__\\__\\  / /\ || |  | /\ \/ /\ |/ /\ | DOT NET        ***
 ***        /_/   \_/___/___/ /_____\|_|  |____/_____\\__/\|                ***
 ***       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~        ***
 ***              [http://assarbad.net | http://assarbad.org]               ***
 ***                                                                        ***
 ***   Notes:                                                               ***
 ***   - my first name is Oliver, you may well use this in your e-mails     ***
 ***   - for questions and/or proposals drop me a mail or instant message   ***
 ***                                                                        ***
 ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***
 ***              May the source be with you, stranger ... ;)               ***
 ***    Snizhok, eto ne tolko fruktovij kefir, snizhok, eto stil zhizn.     ***
 ***                     Vsem Privet iz Germanij                            ***
 ***                                                                        ***
 *** IN MEMORIAM                                                            ***
 *** Melkij died on 2005-07-17 after he had suffered from a seldom disease  ***
 *** for a long time.                                                       ***
 ***                                                                        ***
 *** Greets from -=Assarbad=- fly to YOU =)                                 ***
 *** Special greets fly 2 Nico, Casper, SA, Pizza, Navarion, Eugen, Zhenja, ***
 *** Xandros, Strelok etc pp.                                               ***
 ***                                                                        ***
 *** Thanks to:                                                             ***
 *** W.A. Mozart, Vivaldi, Beethoven, Poeta Magica, Kurtzweyl, Manowar,     ***
 *** Blind Guardian, Weltenbrand, In Extremo, Wolfsheim, Carl Orff, Zemfira ***
 *** ... most of my work was done with their music in the background ;)     ***
 ***                                                                        ***
 ******************************************************************************
 ******************************************************************************

 This code is released into the PUBLIC DOMAIN. However, there's a disclaimer!

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                             .oooO     Oooo.
 ____________________________(   )_____(   )___________________________________
                              \ (       ) /
                               \_)     (_/

 ******************************************************************************)
unit MD5;
interface

uses
  Windows;

type
  TMD5state = array[0..3] of DWORD;
  TMD5digest = array[0..15] of Byte;
  TMD5_CTX = record
    State: TMD5state;
    Count: array[0..1] of DWORD;
    Buffer: array[0..63] of Byte;
  end;

// Functions provided in the original MD5.C from RFC1321
procedure MD5Init(var Context: TMD5_CTX);
procedure MD5Update(var Context: TMD5_CTX; lpInput: PChar; cbLen: DWORD);
procedure MD5Final(var Context: TMD5_CTX; var Digest: TMD5digest);

// Additional functions
function MD5_Hash_OverBuffer(buf: Pointer; cblen: DWORD): TMD5digest;
function MD5_Hash_OverFileByHandle(hFile: THandle): TMD5Digest;
function MD5_Hash2String(MD5: TMD5Digest): String;
function MD5_HashForFileA(pszFName: PAnsiChar): TMD5Digest;
function MD5_HashForFileW(pwsFName: PWideChar): TMD5Digest;

implementation

const
// Constants for MD5Transform routine.
  S11 = 7;
  S12 = 12;
  S13 = 17;
  S14 = 22;
  S21 = 5;
  S22 = 9;
  S23 = 14;
  S24 = 20;
  S31 = 4;
  S32 = 11;
  S33 = 16;
  S34 = 23;
  S41 = 6;
  S42 = 10;
  S43 = 15;
  S44 = 21;

var
  PADDING: array[0..15] of DWORD = (
    $00000080, $00000000,
    $00000000, $00000000,
    $00000000, $00000000,
    $00000000, $00000000,
    $00000000, $00000000,
    $00000000, $00000000,
    $00000000, $00000000,
    $00000000, $00000000
    );

procedure MD5Transform(var State: TMD5state; Buffer: Pointer); forward;

// F, G, H and I are basic MD5 functions.

function F(X, Y, Z: DWORD): DWORD; register;
// #define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
(* EAX = X; EDX = Y; ECX = Z *)
asm
  PUSH   EAX
  AND    EDX, EAX
  POP    EAX
  NOT    EAX
  AND    EAX, ECX
  OR     EAX, EDX
end;

function G(X, Y, Z: DWORD): DWORD; register;
// #define G(x, y, z) (((x) & (z)) | ((y) & (~z)))
(* EAX = X; EDX = Y; ECX = Z *)
asm
  PUSH   ECX
  AND    EAX, ECX
  POP    ECX
  NOT    ECX
  AND    EDX, ECX
  OR     EAX, EDX
end;

function H(X, Y, Z: DWORD): DWORD; register;
// #define H(x, y, z) ((x) ^ (y) ^ (z))
(* EAX = X; EDX = Y; ECX = Z *)
asm
  XOR    EDX, ECX
  XOR    EAX, EDX
end;

function I(X, Y, Z: DWORD): DWORD; register;
// #define I(x, y, z) ((y) ^ ((x) | (~z)))
(* EAX = X; EDX = Y; ECX = Z *)
asm
  NOT    ECX
  OR     EAX, ECX
  XOR    EAX, EDX
end;

{
function ROTATE_LEFT(X: DWORD; N: Byte): DWORD; register;
// ROTATE_LEFT rotates x left n bits.
// #define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))
(* EAX = X; EDX = N *)
asm
  MOV    ECX, EDX
  ROL    EAX, CL
end;
}

procedure Rounds(var A: DWORD; B, C, D, X: DWORD; S: Byte; AC: DWORD; Func: Pointer); register;
// FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
// Rotation is separate from addition to prevent recomputation.
(*
#define FuncFuncF(a, b, c, d, x, s, ac) { \
 (a) += Func ((b), (c), (d)) + (x) + (UINT4)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \  }
*)
asm
  PUSH    EDX // save B
  PUSH    EAX // save @A
  MOV     EAX, EDX // EAX:=B
  MOV     EDX, ECX // EDX:=C
  MOV     ECX, D // ECX := D
  CALL    Func // Call the function given as a pointer. It depends on the round!
  POP     EDX // restore @A
  PUSH    EDX // save @A
  ADD     EAX, [EDX] // EAX:=A + F(B,C,D)
  ADD     EAX, X // ... + X
  ADD     EAX, AC // ... + AC
  MOVZX   ECX, S // EDX:=S
  ROL     EAX, CL
//  CALL    ROTATE_LEFT // <- replaced by 1 ROL op ... see above.
  POP     EDX // restore @A
  POP     ECX // restore B
  ADD     EAX, ECX // A:=A+B
  MOV     [EDX], EAX
// A := ROTATE_LEFT(A + Func(B, C, D) + X + AC, S) + B;
end;

procedure Encode(output, input: PChar; cblen: DWORD); register;
(*
  This is more or less a fake function. It copes with the BIG/LITTLE ENDIAN
  problem, since the MD5-algorithm needs to be platform independent. This also
  means, that on other platforms this might include some byte swapping ;)

  Original Description: Encodes input (UINT4) into output (unsigned char).
  Assumes len is a multiple of 4.
*)
begin
  CopyMemory(output, input, cblen);
end;

procedure Decode(output, input: PChar; cblen: DWORD); register;
(*
  This is more or less a fake function. It copes with the BIG/LITTLE ENDIAN
  problem, since the MD5-algorithm needs to be platform independent. This also
  means, that on other platforms this might include some byte swapping ;)

  Original Description: Decodes input (unsigned char) into output (UINT4).
  Assumes len is a multiple of 4.
*)
begin
  CopyMemory(output, input, cblen);
end;

procedure MD5Init(var Context: TMD5_CTX);
// MD5 initialization. Begins an MD5 operation, writing a new context.
begin
  ZeroMemory(@Context, sizeof(Context));
// Load magic initialization constants.
  Context.State[0] := $67452301;
  Context.State[1] := $EFCDAB89;
  Context.State[2] := $98BADCFE;
  Context.State[3] := $10325476;
end;

procedure MD5Update(var Context: TMD5_CTX; lpInput: PChar; cbLen: DWORD);
// MD5 block update operation. Continues an MD5 message-digest
// operation, processing another message block, and updating the
// context.
var
  idx,
    partLen,
    i: DWORD;
begin
// Compute number of bytes mod 64 -> SHR 3 = DIV 8 = DIV 2^3
  idx := (Context.Count[0] shr 3) and $3F;
// Update number of bits -> SHL 3 = MUL 8 = MUL 2^3
  i := cbLen shl 3;
  Context.Count[0] := Context.Count[0] + i;
  if Context.Count[0] < (i) then
    inc(Context.Count[1], 1);
  Context.Count[1] := Context.Count[1] + cbLen shr 29;
  partLen := 64 - idx;
// Transform as many times as possible.
  if cbLen >= partLen then
  begin
    CopyMemory(@Context.Buffer[idx], lpInput, partLen);
    MD5Transform(Context.State, @Context.Buffer);
    i := partLen;
    while i + 63 < cbLen do
    begin
      MD5Transform(Context.State, @lpInput[i]);
      inc(i, 64);
    end;
    idx := 0;
  end
  else i := 0;
// Buffer remaining input
  CopyMemory(@Context.Buffer[idx], @lpInput[I], cbLen - I);
end;

procedure MD5Final(var Context: TMD5_CTX; var Digest: TMD5digest);
// MD5 finalization. Ends an MD5 message-digest operation, writing the
// the message digest and zeroizing the context.
var
  Bits: array[0..7] of Byte;
  idx,
    padLen: DWORD;
begin
// Copy buffer to buffer ... Encode is just a wrapper for this
// Save number of bits
  Encode(@Bits, @Context.Count, 8);
// Pad out to 56 mod 64.
  idx := (Context.Count[0] shr 3) and $3F;
  if (idx < 56) then
    padLen := 56 - idx
  else
    padLen := 120 - idx;
  MD5Update(Context, @PADDING, padLen);
// Append length (before padding)
  MD5Update(Context, @Bits, 8);
// Store state in digest
  Encode(@Digest, @Context.State, 16);
// Zeroize sensitive information.
  ZeroMemory(@Context, sizeof(TMD5_CTX));
end;

procedure MD5Transform(var State: TMD5state; Buffer: Pointer);
// MD5 basic transformation. Transforms state based on block.
var
  a,
    b,
    c,
    d: DWORD;
  x: array[0..15] of DWORD;
begin
// Copy the input buffer into our internal buffer
  Decode(@x, Buffer, 64);
// Init from current context's state
  a := State[0];
  b := State[1];
  c := State[2];
  d := State[3];
// Actual calculation run
// Round 1
  Rounds(a, b, c, d, x[00], S11, $D76AA478, @F); //  1
  Rounds(d, a, b, c, x[01], S12, $E8C7B756, @F); //  2
  Rounds(c, d, a, b, x[02], S13, $242070DB, @F); //  3
  Rounds(b, c, d, a, x[03], S14, $C1BDCEEE, @F); //  4
  Rounds(a, b, c, d, x[04], S11, $F57C0FAF, @F); //  5
  Rounds(d, a, b, c, x[05], S12, $4787C62A, @F); //  6
  Rounds(c, d, a, b, x[06], S13, $A8304613, @F); //  7
  Rounds(b, c, d, a, x[07], S14, $FD469501, @F); //  8
  Rounds(a, b, c, d, x[08], S11, $698098D8, @F); //  9
  Rounds(d, a, b, c, x[09], S12, $8B44F7AF, @F); // 10
  Rounds(c, d, a, b, x[10], S13, $FFFF5BB1, @F); // 11
  Rounds(b, c, d, a, x[11], S14, $895CD7BE, @F); // 12
  Rounds(a, b, c, d, x[12], S11, $6B901122, @F); // 13
  Rounds(d, a, b, c, x[13], S12, $FD987193, @F); // 14
  Rounds(c, d, a, b, x[14], S13, $A679438E, @F); // 15
  Rounds(b, c, d, a, x[15], S14, $49B40821, @F); // 16
// Round 2
  Rounds(a, b, c, d, x[01], S21, $F61E2562, @G); // 17
  Rounds(d, a, b, c, x[06], S22, $C040B340, @G); // 18
  Rounds(c, d, a, b, x[11], S23, $265E5A51, @G); // 19
  Rounds(b, c, d, a, x[00], S24, $E9B6C7AA, @G); // 20
  Rounds(a, b, c, d, x[05], S21, $D62F105D, @G); // 21
  Rounds(d, a, b, c, x[10], S22, $02441453, @G); // 22
  Rounds(c, d, a, b, x[15], S23, $D8A1E681, @G); // 23
  Rounds(b, c, d, a, x[04], S24, $E7D3FBC8, @G); // 24
  Rounds(a, b, c, d, x[09], S21, $21E1CDE6, @G); // 25
  Rounds(d, a, b, c, x[14], S22, $C33707D6, @G); // 26
  Rounds(c, d, a, b, x[03], S23, $F4D50D87, @G); // 27
  Rounds(b, c, d, a, x[08], S24, $455A14ED, @G); // 28
  Rounds(a, b, c, d, x[13], S21, $A9E3E905, @G); // 29
  Rounds(d, a, b, c, x[02], S22, $FCEFA3F8, @G); // 30
  Rounds(c, d, a, b, x[07], S23, $676F02D9, @G); // 31
  Rounds(b, c, d, a, x[12], S24, $8D2A4C8A, @G); // 32
// Round 3
  Rounds(a, b, c, d, x[05], S31, $FFFA3942, @H); // 33
  Rounds(d, a, b, c, x[08], S32, $8771F681, @H); // 34
  Rounds(c, d, a, b, x[11], S33, $6D9D6122, @H); // 35
  Rounds(b, c, d, a, x[14], S34, $FDE5380C, @H); // 36
  Rounds(a, b, c, d, x[01], S31, $A4BEEA44, @H); // 37
  Rounds(d, a, b, c, x[04], S32, $4BDECFA9, @H); // 38
  Rounds(c, d, a, b, x[07], S33, $F6BB4B60, @H); // 39
  Rounds(b, c, d, a, x[10], S34, $BEBFBC70, @H); // 40
  Rounds(a, b, c, d, x[13], S31, $289B7EC6, @H); // 41
  Rounds(d, a, b, c, x[00], S32, $EAA127FA, @H); // 42
  Rounds(c, d, a, b, x[03], S33, $D4EF3085, @H); // 43
  Rounds(b, c, d, a, x[06], S34, $04881D05, @H); // 44
  Rounds(a, b, c, d, x[09], S31, $D9D4D039, @H); // 45
  Rounds(d, a, b, c, x[12], S32, $E6DB99E5, @H); // 46
  Rounds(c, d, a, b, x[15], S33, $1FA27CF8, @H); // 47
  Rounds(b, c, d, a, x[02], S34, $C4AC5665, @H); // 48
// Round 4
  Rounds(a, b, c, d, x[00], S41, $F4292244, @I); // 49
  Rounds(d, a, b, c, x[07], S42, $432AFF97, @I); // 50
  Rounds(c, d, a, b, x[14], S43, $AB9423A7, @I); // 51
  Rounds(b, c, d, a, x[05], S44, $FC93A039, @I); // 52
  Rounds(a, b, c, d, x[12], S41, $655B59C3, @I); // 53
  Rounds(d, a, b, c, x[03], S42, $8F0CCC92, @I); // 54
  Rounds(c, d, a, b, x[10], S43, $FFEFF47D, @I); // 55
  Rounds(b, c, d, a, x[01], S44, $85845DD1, @I); // 56
  Rounds(a, b, c, d, x[08], S41, $6FA87E4F, @I); // 57
  Rounds(d, a, b, c, x[15], S42, $FE2CE6E0, @I); // 58
  Rounds(c, d, a, b, x[06], S43, $A3014314, @I); // 59
  Rounds(b, c, d, a, x[13], S44, $4E0811A1, @I); // 60
  Rounds(a, b, c, d, x[04], S41, $F7537E82, @I); // 61
  Rounds(d, a, b, c, x[11], S42, $BD3AF235, @I); // 62
  Rounds(c, d, a, b, x[02], S43, $2AD7D2BB, @I); // 63
  Rounds(b, c, d, a, x[09], S44, $EB86D391, @I); // 64
// Write new 'state' back
  State[0] := State[0] + a;
  State[1] := State[1] + b;
  State[2] := State[2] + c;
  State[3] := State[3] + d;
// Zeroize sensitive information.
  ZeroMemory(@x, sizeof(x));
end;

function MD5_Hash_OverBuffer(buf: Pointer; cblen: DWORD): TMD5digest;
(*
  This calculates the hash over a memory buffer.
  Note, that the context is initialized AND finalized! This means, that you
  cannot continue calculation ... this is a full cycle of hash calculation!
*)
var
  Context: TMD5_CTX;
begin
  MD5Init(Context);
  MD5Update(Context, buf, cblen);
  MD5Final(Context, Result);
end;

function MD5_Hash_OverFileByHandle(hFile: THandle): TMD5Digest;
(*
  Maps a file into the process' memory and calculates a hash over it.
  Maximum file size supported is 2^32 Bytes.
  The file handle passed as a parameter must grant read access. If the file
  cannot be mapped, the function sets the last error to ERROR_ACCESS_DENIED.
  On success this is set to ERROR_SUCCESS. Use GetLastError to retrieve this
  state.
*)
var
  hMap: THandle;
  pView: Pointer;
  Context: TMD5_CTX;
  dwFSize: DWORD;
begin
  SetLastError(ERROR_ACCESS_DENIED);
  hMap := CreateFileMapping(hFile, nil, PAGE_READONLY, 0, 0, nil);
  if hMap <> 0 then
  try
    dwFSize := GetFileSize(hFile, nil); // No more than 2^32 Byte file size
    pView := MapViewOfFile(hMap, FILE_MAP_READ, 0, 0, 0);
    if pView <> nil then
    try
      MD5Init(Context);
      MD5Update(Context, pView, dwFSize);
      MD5Final(Context, Result);
      SetLastError(ERROR_SUCCESS);
    finally
      UnmapViewOfFile(pView);
    end;
  finally
    CloseHandle(hMap);
  end;
end;

function MD5_HashForFileW(pwsFName: PWideChar): TMD5Digest;
var
  hFile: THandle;
begin
  hFile := CreateFileW(
    pwsFName,
    GENERIC_READ,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,
    0);
  if hFile <> INVALID_HANDLE_VALUE then
  try
    result := MD5_Hash_OverFileByHandle(hFile);
  finally
    CloseHandle(hFile);
  end;
end;

function MD5_HashForFileA(pszFName: PAnsiChar): TMD5Digest;
var
  hFile: THandle;
begin
  hFile := CreateFileA(
    pszFName,
    GENERIC_READ,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,
    0);
  if hFile <> INVALID_HANDLE_VALUE then
  try
    result := MD5_Hash_OverFileByHandle(hFile);
  finally
    CloseHandle(hFile);
  end;
end;

{
  Danke an Sharky, der mich darauf hinwies, dass die Benutzer
  eine solche Funktion wohl lieber aufrufen würden.
  
  Sharky ist Moderator in der DP -> http://www.delphipraxis.net/user4.html
}
function MD5_HashForString(aValue: String): TMD5Digest;
var
  Context: TMD5_CTX; 
begin 
  MD5Init(Context); 
  MD5Update(Context, @aValue[1], Length(aValue));
  MD5Final(Context, Result); 
end;

function MD5_Hash2String(MD5: TMD5Digest): String;
var
  arr:array[0..32] of Char; // 33 characters. One more than 32 for trailing zero.
begin
  asm
    MOV    EAX, DWORD PTR [MD5+$00]
    BSWAP  EAX
    MOV    DWORD PTR [MD5+$00], EAX
    SUB    EDX, 4
    MOV    EAX, DWORD PTR [MD5+$04]
    BSWAP  EAX
    MOV    DWORD PTR [MD5+$04], EAX
    SUB    EDX, 4
    MOV    EAX, DWORD PTR [MD5+$08]
    BSWAP  EAX
    MOV    DWORD PTR [MD5+$08], EAX
    SUB    EDX, 4
    MOV    EAX, DWORD PTR [MD5+$0C]
    BSWAP  EAX
    MOV    DWORD PTR [MD5+$0C], EAX
  end;
  ZeroMemory(@arr, sizeof(arr));
  wvsprintf(@arr, '%8.8x%8.8x%8.8x%8.8x', PChar(@MD5));
  SetString(Result, arr, lstrlen(arr));
end;

end.

