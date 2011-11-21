unit savegame;
interface

procedure SaveGame(const SaveName:String);

implementation

const SaveGameAddr:Cardinal=$004C0280;

procedure SaveGame(const SaveName:String);
asm
  int 3;
  pushad;
  push 1;
  Call pointer(SaveGameAddr);
  popad;
end;

end.