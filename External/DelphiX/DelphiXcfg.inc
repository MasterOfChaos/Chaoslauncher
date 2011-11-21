{$B-,J+,Q-,R-,T-,X+}

{$IFDEF WIN32}
  {$DEFINE DX_Win32}
{$ELSE}
  {$DEFINE DX_Win16}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE DX_Delphi6}
{$ENDIF}

{$IFDEF VER130}
  {$DEFINE DX_Delphi5}
{$ENDIF}

{$IFDEF VER120}
  {$DEFINE DX_Delphi4}
{$ENDIF}

{$IFDEF VER100}
  {$DEFINE DX_Delphi3}
{$ENDIF}

{$IFDEF VER90}
  {$DEFINE DX_Delphi2}
{$ENDIF}

{$IFDEF VER80}
  {$DEFINE DX_Delphi1}
{$ENDIF}

{$IFDEF DX_Delphi2}
  {$DEFINE DX_Delphi2_Up}
{$ENDIF}

{$IFDEF DX_Delphi3}
  {$DEFINE DX_Delphi2_Up}
  {$DEFINE DX_Delphi3_Up}
{$ENDIF}

{$IFDEF DX_Delphi4}
  {$DEFINE DX_Delphi2_Up}
  {$DEFINE DX_Delphi3_Up}
  {$DEFINE DX_Delphi4_Up}
{$ENDIF}

{$IFDEF DX_Delphi5}
  {$DEFINE DX_Delphi2_Up}
  {$DEFINE DX_Delphi3_Up}
  {$DEFINE DX_Delphi4_Up}
  {$DEFINE DX_Delphi5_Up}
{$ENDIF}

{$IFDEF DX_Delphi6}
  {$DEFINE DX_Delphi2_Up}
  {$DEFINE DX_Delphi3_Up}
  {$DEFINE DX_Delphi4_Up}
  {$DEFINE DX_Delphi5_Up}
  {$DEFINE DX_Delphi6_Up}
{$ENDIF}
