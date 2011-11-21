unit SectionStream;

interface
uses classes,streaming;

type TSectionReader=class(TStream)
  public
    property Valid:boolean;
    function NextSection:boolean;
    constructor Create(Stream:TStream);
end;

implementation

end.
