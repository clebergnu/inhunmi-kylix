unit InhEncomendaDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  QControls, DateUtils, InhBiblio, InhDbForm, InhStringResources, InhConfig;

type
  TEncomendaDM = class(TDataModule)
    EncomendaDSet: TSQLClientDataSet;
    EncomendaDSource: TDataSource;
    ConsumoDSet: TSQLClientDataSet;
    ConsumoDSource: TDataSource;
    PortaConsumoDSet: TSQLClientDataSet;
    PortaConsumoDSource: TDataSource;
    NomeTelefoneDSource: TDataSource;
    PortaConsumoDSetid: TIntegerField;
    PortaConsumoDSetdono: TIntegerField;
    PortaConsumoDSetstatus: TStringField;
    PortaConsumoDSetdono_nome: TStringField;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    ConsumoDSetid: TIntegerField;
    ConsumoDSetproduto: TIntegerField;
    ConsumoDSetproduto_quantidade: TIntegerField;
    ConsumoDSetvalor: TFloatField;
    ConsumoDSetproduto_descricao: TStringField;
    ConsumoDSetdono: TIntegerField;
    ConsumoDSettotal: TAggregateField;
    EncomendaDSetdono: TIntegerField;
    EncomendaDSettipo_entrega: TStringField;
    EncomendaDSetlocal_entrega: TStringField;
    EncomendaDSettaxa_entrega: TFloatField;
    EncomendaDSetobservacoes: TStringField;
    EnderecoDSet: TSQLClientDataSet;
    EnderecoDSource: TDataSource;
    NomeTelefoneDSet: TSQLClientDataSet;
    EncomendaDSetdatahora_entrega: TSQLTimeStampField;
    EncomendaDSetusuario: TIntegerField;
    ConsumoDSetusuario: TIntegerField;
    PortaConsumoDSettipo: TStringField;
    PortaConsumoDSetdatahora_inicial: TSQLTimeStampField;
    ConsumoDSetdepartamento_venda: TIntegerField;
    ConsumoDSetdatahora_inicial: TSQLTimeStampField;
    procedure PortaConsumoDSetAfterPost(DataSet: TDataSet);
    procedure DetailBeforePost(DataSet: TDataSet);
    procedure PortaConsumoDSetBeforeDelete(DataSet: TDataSet);
    procedure DetailAfterPost(DataSet: TDataSet);
    procedure EncomendaDSetBeforePost(DataSet: TDataSet);
    procedure PortaConsumoDSetBeforePost(DataSet: TDataSet);
    procedure EncomendaDSetAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function  DMOpen () : boolean;
  end;

var
  EncomendaDM: TEncomendaDM;

implementation

uses InhDlgUtils, InhEncomendaUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function  TEncomendaDM.DMOpen () : boolean;
begin
   if (InhDataSetOpenMaster(EncomendaDM.PortaConsumoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenJoint(EncomendaDM.EncomendaDSet, EncomendaDM.PortaConsumoDset) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenDetail(EncomendaDM.ConsumoDSet, EncomendaDM.PortaConsumoDset) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(EncomendaDM.NomeTelefoneDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(EncomendaDM.ProdutoDSet) = False) then
      begin
         Result := False;
         exit;
      end;

   Result := True;
end;

// Master's AfterPost event handler
procedure TEncomendaDM.PortaConsumoDSetAfterPost(DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);
   if EncomendaDSet.RecordCount = 0 then
      begin
         EncomendaDSet.Append;
         EncomendaDSet.FieldValues['dono'] := DataSet.FieldValues['id'];
         EncomendaDSet.ApplyUpdates(-1);
         EncomendaDSet.Refresh;
      end
   else
      begin
         EncomendaDSet.ApplyUpdates(-1);
         EncomendaDSet.Refresh;
      end;
   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
 end;

// Confirmation of Master/Detail records deletion
procedure TEncomendaDM.PortaConsumoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Encomenda') = True then
      begin
         if InhEncomendaDelete (DataSet.FieldByName('id').AsInteger) then
            begin
               DbForm.StatusBar.SimpleText := Format ('Encomenda código %u excluída.',
                                                      [DataSet.FieldByName('id').AsInteger]);
               DataSet.Refresh;
               DataSet.AfterScroll(DataSet);
            end;
      end;
   Abort;
end;

// Detail's BeforePost event handler
procedure TEncomendaDM.DetailBeforePost(DataSet: TDataSet);
begin
    if TSQLClientDataSet(DataSet).State = dsInsert then
      begin
         DataSet.FieldByName('dono').AsInteger := PortaConsumoDSet.FieldByName('id').AsInteger;
         DataSet.FieldByName('valor').AsFloat := (ProdutoDSet.FieldValues['preco_venda'] * DataSet.FieldValues['produto_quantidade']);
         DataSet.FieldByName('usuario').AsString := InhAccess.id;
         DataSet.FieldByName('datahora_inicial').AsDateTime := Now();
         DataSet.FieldByName('departamento_venda').AsString := LocalConfig.ReadString('Atendimento', 'DepartamentoVenda', '');
         DataSet.Tag := 111;
      end
    else
       begin
         // Posiciona o ProdutoDSet corretamente, de acordo com
         // o produto no ConsumoDSet
         ProdutoDSet.FindKey([ConsumoDSet.FieldValues['produto']]);
         DataSet.FieldValues['valor'] := (ProdutoDSet.FieldValues['preco_venda'] * DataSet.FieldValues['produto_quantidade']);
         DataSet.FieldValues['usuario'] := InhAccess.id;
       end
end;

procedure TEncomendaDM.DetailAfterPost(DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost (DataSet);
end;

procedure TEncomendaDM.EncomendaDSetBeforePost(DataSet: TDataSet);
begin
   if DataSet.State in [dsInsert] then
      begin
         DataSet.FieldByName('datahora_entrega').AsDateTime := Today();
         DataSet.FieldByName('usuario').AsString := InhAccess.id;
      end;
end;

procedure TEncomendaDM.PortaConsumoDSetBeforePost(DataSet: TDataSet);
begin
   if DataSet.State in [dsInsert] then
      begin
         DataSet.FieldByName('datahora_inicial').AsDateTime := Now();
         DataSet.Tag := 111
      end
//    else if DataSet.State = dsEdit then
//         InhStatusChangedRecord (DbForm.StatusBar, TSQLClientDataSet(DataSet).FieldValues['id']);
end;

procedure TEncomendaDM.EncomendaDSetAfterPost(DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost(DataSet);
end;

end.
