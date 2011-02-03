unit InhCompraDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS;

type
  TCompromissoDM = class(TDataModule)
    CompromissoDSet: TSQLClientDataSet;
    CompromissoDSource: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CompromissoDM: TCompromissoDM;

implementation

{$R *.xfm}

end.
