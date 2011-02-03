unit InhPessoaInstituicaoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhBiblio;

type
  TPessoaInstituicaoDM = class(TDataModule)
    PessoaInstituicaoDSet: TSQLClientDataSet;
    PessoaInstituicaoDSetid: TIntegerField;
    PessoaInstituicaoDSetnome: TStringField;
    procedure PessoaInstituicaoDSetAfterDelete(DataSet: TDataSet);
    procedure PessoaInstituicaoDSetBeforePost(DataSet: TDataSet);
    procedure PessoaInstituicaoDSetAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PessoaInstituicaoDM: TPessoaInstituicaoDM;

implementation

{$R *.xfm}

procedure TPessoaInstituicaoDM.PessoaInstituicaoDSetAfterDelete(
  DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost(DataSet);
end;

procedure TPessoaInstituicaoDM.PessoaInstituicaoDSetBeforePost(
  DataSet: TDataSet);
begin
   if TSQLClientDataSet(DataSet).State = dsInsert then
      begin
         DataSet.FieldValues['id'] := '0';
         DataSet.Tag := 111;
      end;
end;

procedure TPessoaInstituicaoDM.PessoaInstituicaoDSetAfterPost(
  DataSet: TDataSet);
begin
   InhDataSetMasterAfterPost (DataSet);
end;

end.
