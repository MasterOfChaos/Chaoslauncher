unit Sync;

interface

procedure AquireHelperMutex;
procedure ReleaseHelperMutex;

implementation
uses SyncObjs;
var HelperMutex:TMutex;

procedure AquireHelperMutex;
begin
  HelperMutex.Acquire;
end;

procedure ReleaseHelperMutex;
begin
  HelperMutex.Release;
end;

initialization
  HelperMutex:=TMutex.create;
finalization
  AquireHelperMutex;
  HelperMutex.free;
end.
