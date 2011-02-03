unit InhPortaConsumoFixoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhDbForm, InhBiblio, InhStringResources;

type
  TPortaConsumoFixoDM = class(TDataModule)
    PortaConsumoFixoDSet: TSQLClientDataSet;
    PortaConsumoFixoDSource: TDataSource;
    DonoDSet: TSQLClientDataSet;
    DonoDSource: TDataSource;
    PortaConsumoFixoDSetid: TIntegerField;
    PortaConsumoFixoDSetnumero: TIntegerField;
    PortaConsumoFixoDSettipo: TStringField;
    PortaConsumoFixoDSettipo_invalido: TStringField;
    PortaConsumoFixoDSettipo_automatico: TStringField;
    PortaConsumoFixoDSetdono: TIntegerField;
    PortaConsumoFixoDSetobservacao: TStringField;
    DonoDSetid: TIntegerField;
    DonoDSetnome: TStringField;
    PortaConsumoFixoDSetdono_nome: TStringField;
    procedure PortaConsumoFixoDSetAfterPost(DataSet: TDataSet);
    procedure PortaConsumoFixoDSetBeforeDelete(DataSet: TDataSet);
  private
  public
     DbForm : TInhDbForm;
     function  DMOpen () : boolean;
  end;

var
  PortaConsumoFixoDM: TPortaConsumoFixoDM;

implementation

uses InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening


{ TPortaConsumoFixoDM }

function TPortaConsumoFixoDM.DMOpen: boolean;
begin
   // DataSets that should always be opened
   if (InhDataSetOpenMaster(PortaConsumoFixoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(DonoDset) = False) then
      begin
         Result := False;
         exit;
      end;
   Result := True;
end;

procedure TPortaConsumoFixoDM.PortaConsumoFixoDSetAfterPost(
  DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);
   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

procedure TPortaConsumoFixoDM.PortaConsumoFixoDSetBeforeDelete(
  DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Porta Consumo') <> True then
      Abort;
end;

end.
