unit SoundAt;

interface
uses DxSounds,math;
procedure PlaySoundLeft(const Sound:TWaveCollectionItem;const Wait:boolean=false);
procedure PlaySoundRight(const Sound:TWaveCollectionItem;const Wait:boolean=false);

Procedure PlaySoundAt(const Sound:TWaveCollectionItem;const x,y:real);overload;
Procedure PlaySoundAt(const Sound:TWaveCollectionItem;const Wait:boolean;const x,y:real);overload;

var PanDist:real;
    VolumeDist:real;
    MinVolume:integer;
implementation

procedure PlaySoundLeft(const Sound:TWaveCollectionItem;const Wait:boolean=false);
var OrgPan:integer;
Begin
 try
  OrgPan:=Sound.Pan;
  Sound.Pan:=-10000;
  Sound.play(Wait);
 finally
  Sound.Pan:=OrgPan;
 end;
End;

procedure PlaySoundRight(const Sound:TWaveCollectionItem;const Wait:boolean=false);
var OrgPan:integer;
Begin
 try
  OrgPan:=Sound.Pan;
  Sound.Pan:=10000;
  Sound.play(Wait);
 finally
  Sound.Pan:=OrgPan;
 end;
End;

Procedure PlaySoundAt(const Sound:TWaveCollectionItem;const x,y:real);overload;
Begin
 PlaySoundAt(Sound,false,x,y);
End;
Procedure PlaySoundAt(const Sound:TWaveCollectionItem;const Wait:boolean;const x,y:real);overload;
var OrgVolume,OrgPan:integer;
Begin
 try
  OrgVolume:=Sound.volume;
  OrgPan:=Sound.Pan;
  Sound.volume:=round((OrgVolume-MinVolume)/Max(1,sqrt(sqr(x)+sqr(y))/VolumeDist))+MinVolume;
  Sound.Pan:=round(10000*x/Max(5,sqrt(sqr(x)+sqr(y))));
  Sound.play(Wait);
 finally
  Sound.volume:=OrgVolume;
  Sound.Pan:=OrgPan;
 end;
End;
initialization
 VolumeDist:=1;
 PanDist:=1.5;
 MinVolume:=-2000;
end.
 