unit InhPortaConsumoPropriedadesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QExtCtrls, QButtons, Provider, SqlExpr, DB, DBClient,
  DBLocal, DBLocalS, InhMainDM, QStdCtrls, QMask, QDBCtrls, QComCtrls,
  QGrids, QDBGrids, InhBiblio, Qt, InhConsumoPropriedadesDlg, InhLookUpPadrao,
  QMenus, QTypes, QActnList, DBXpress, InhConsumoUtils;

type
  TInhPortaConsumoPropriedadesDlgForm = class(TInhOkCancelDlgForm)
    PortaConsumoDSet: TSQLClientDataSet;
    PortaConsumoDSource: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    IdDbEdit: TDBEdit;
    NumeroDbEdit: TDBEdit;
    Label3: TLabel;
    TipoDbComboBox: TDBComboBox;
    DetailsPageControl: TPageControl;
    DetalhesTabSheet: TTabSheet;
    ConsumoDSource: TDataSource;
    ConsumoDSet: TSQLClientDataSet;
    Label5: TLabel;
    StatusDbComboBox: TDBComboBox;
    DonoDSet: TSQLClientDataSet;
    DonoDSource: TDataSource;
    PortaConsumoDSetid: TIntegerField;
    PortaConsumoDSetnumero: TIntegerField;
    PortaConsumoDSettipo: TStringField;
    PortaConsumoDSetstatus: TStringField;
    PortaConsumoDSetdatahora: TSQLTimeStampField;
    PortaConsumoDSetdatahora_inicial: TSQLTimeStampField;
    PortaConsumoDSetdatahora_final: TSQLTimeStampField;
    PortaConsumoDSetdono: TIntegerField;
    PortaConsumoDSetusuario: TIntegerField;
    PortaConsumoDSetstatus_anterior: TStringField;
    PortaConsumoDSetdono_nome: TStringField;
    DonoDSetid: TIntegerField;
    DonoDSetnome: TStringField;
    ActionList1: TActionList;
    OutrasFuncoesPopupMenu: TPopupMenu;
    OutrasFuncoesSpeedButton: TSpeedButton;
    DonoButton: TButton;
    GroupBox1: TGroupBox;
    DataHoraInicialLabel: TLabel;
    DataHoraInicialDbEdit: TDBEdit;
    DataHoraFinalLabel: TLabel;
    DataHoraFinalDbEdit: TDBEdit;
    DataHoraAlteracaoDbEdit: TDBEdit;
    Label4: TLabel;
    DonoNomeDbEdit: TDBEdit;
    TabSheet1: TTabSheet;
    PagamentosTabSheet: TTabSheet;
    ConsumoDSetid: TIntegerField;
    ConsumoDSetproduto_quantidade: TIntegerField;
    ConsumoDSetvalor: TFloatField;
    ConsumosDbGrid: TDBGrid;
    PagamentosDbGrid: TDBGrid;
    PagamentoDSource: TDataSource;
    PagamentoDSet: TSQLClientDataSet;
    TrocosTabSheet: TTabSheet;
    DBGrid1: TDBGrid;
    PagamentoDSetvalor: TFloatField;
    PagamentoDSetdescricao: TStringField;
    UsuarioDbEdit: TDBEdit;
    Label7: TLabel;
    StatusAnteriorDbEdit: TDBEdit;
    TrocoDSet: TSQLClientDataSet;
    TrocoDSource: TDataSource;
    TrocoDSetvalor: TFloatField;
    TrocoDSetdescricao: TStringField;
    UsuarioButton: TButton;
    UsuarioDSet: TSQLClientDataSet;
    UsuarioDSource: TDataSource;
    UsuarioDSetid: TIntegerField;
    UsuarioDSetusuario: TStringField;
    PortaConsumoDSetusuario_nome: TStringField;
    RemoverConsumos: TAction;
    RemoverPagamentosTrocos: TAction;
    LimpaPortaConsumo: TAction;
    PortaConsumo1: TMenuItem;
    LimparPortaConsumoRemoveConsumosPagamentoseTrocos1: TMenuItem;
    Consumo1: TMenuItem;
    Pagamentos1: TMenuItem;
    RemoverTodosConsumos1: TMenuItem;
    RemoverPagamentos1: TMenuItem;
    DesfazerPagamentoFechamento: TAction;
    DesfazerPagamento1: TMenuItem;
    ConsumoDSetproduto_descricao: TStringField;
    procedure ConsumoDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure DonoButtonClick(Sender: TObject);
    procedure OutrasFuncoesSpeedButtonClick(Sender: TObject);
    procedure DetailsPageControlPageChanging(Sender: TObject;
      NewPage: TTabSheet; var AllowChange: Boolean);
    procedure UsuarioButtonClick(Sender: TObject);
    procedure ConsumosDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RemoverConsumosExecute(Sender: TObject);
    procedure RemoverPagamentosTrocosExecute(Sender: TObject);
    procedure LimpaPortaConsumoExecute(Sender: TObject);
    procedure DesfazerPagamentoFechamentoExecute(Sender: TObject);
  private
    ID : integer;
    function UpdateQuery : boolean;
  public
    { Public declarations }
  end;

  procedure PortaConsumoPropriedadesDlgNewRun (AOwner : TComponent; ID : integer);

implementation

uses InhDlgUtils;

{$R *.xfm}

function PortaConsumoPropriedadesDlgNew (AOwner : TComponent; ID : integer): TInhPortaConsumoPropriedadesDlgForm;
var
   MyForm : TInhPortaConsumoPropriedadesDlgForm;
begin
   MyForm := TInhPortaConsumoPropriedadesDlgForm.Create(AOwner);

   MyForm.ID := ID;

   Result := MyForm;
end;

procedure PortaConsumoPropriedadesDlgNewRun (AOwner : TComponent; ID : Integer);
var
   MyForm : TInhPortaConsumoPropriedadesDlgForm;
begin
   MyForm := PortaConsumoPropriedadesDlgNew (AOwner, ID);

   if (MyForm.UpdateQuery() = False) then
      begin
         FreeAndNil(MyForm);
         exit;
      end
   else
      MyForm.ShowModal;
end;

function TInhPortaConsumoPropriedadesDlgForm.UpdateQuery : boolean;
begin
   PortaConsumoDSet.Params[0].AsInteger := ID;
   PortaConsumoDSet.Open;

   if (PortaConsumoDSet.RecordCount = 0) then
      begin
         InhDlg('Erro: O Porta-Consumo não foi localizado.');
         Result := False;
         exit;
      end;

   DonoDSet.Open;

   ConsumODSet.Params[0].AsInteger := ID;
   PagamentoDSet.Params[0].AsInteger := ID;
   TrocoDSet.Params[0].AsInteger := ID;

   Result := True;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.ConsumoDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (TDbGrid(Sender).DataSource.DataSet.RecordCount = 0) then exit;
   if (Shift = [ssShift]) and (Key = Key_Delete) then
      begin
         if (InhDlgRecordDetailDeleteConfirmation('Consumo')) then
            begin
               InhDeleteFromTableWhereFieldValue ('consumo', 'id',
                                                  TDBGrid(Sender).DataSource.DataSet.FieldValues['id']);
               ConsumoDSet.Refresh;
            end;
      end
   else if (Shift = [ssShift]) and ((Key = Key_Return) or (Key = Key_Enter)) then
      begin
         ConsumoPropriedadesDlgNewRun (Self, TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsInteger);
         ConsumoDSet.Refresh;
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   if (PortaConsumoDSet.State in [dsEdit]) then
      begin
         PortaConsumoDSet.Post;
         PortaConsumoDSet.ApplyUpdates(-1);
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.DonoButtonClick(
  Sender: TObject);
begin
  inherited;
   if (InhLookUpFromDataSource (DonoDSource, 'nome') = mrOk) then
      begin
         PortaConsumoDSet.Edit;
         PortaConsumoDSet.FieldByName('dono').AsInteger := DonoDSet.FieldByName('id').AsInteger;
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.OutrasFuncoesSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
  OutrasFuncoesPopUpMenu.Popup(TForm(Self).Left + TWidgetControl(Sender).Left + TWidgetControl(Sender).Width + 5,
                               TForm(Self).Top + TWidgetControl(Sender).Top);
end;

procedure TInhPortaConsumoPropriedadesDlgForm.DetailsPageControlPageChanging(
  Sender: TObject; NewPage: TTabSheet; var AllowChange: Boolean);
begin
  inherited;
  case NewPage.PageIndex of
     1: InhDataSetOpenMaster(ConsumoDSet);
     2: InhDataSetOpenMaster(PagamentoDSet);
     3: InhDataSetOpenMaster(TrocoDSet);
  end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.UsuarioButtonClick(
  Sender: TObject);
begin
  inherited;
   if (InhLookUpFromDataSource (UsuarioDSource, 'usuario') = mrOk) then
      begin
         PortaConsumoDSet.Edit;
         PortaConsumoDSet.FieldByName('usuario').AsInteger := UsuarioDSet.FieldByName('id').AsInteger;
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.ConsumosDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
   if (TDbGrid(Sender).DataSource.DataSet.RecordCount = 0) then exit;

   if (Shift = [ssShift]) and ((Key = Key_Enter) or (Key = Key_Return)) then
      ConsumoPropriedadesDlgNewRun (Self, ID)
   else if
      (Shift = [ssShift]) and (Key = Key_Delete) then
         begin
            InhConsumoDelete(TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsInteger,
                             InhConsumoDSetQuantidadeDescricaoValor(TDbGrid(Sender).DataSource.DataSet));
            TDbGrid(Sender).DataSource.DataSet.Refresh;
         end;

end;

procedure TInhPortaConsumoPropriedadesDlgForm.RemoverConsumosExecute(
  Sender: TObject);
begin
  inherited;
   if (InhDlgYesNo('Confirma a deleção de todos os consumos?')) then
      begin
         InhRunQuery('DELETE FROM consumo WHERE dono = ' + IntToStr(ID));
         if (ConsumoDSet.Active) then ConsumoDSet.Refresh;
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.RemoverPagamentosTrocosExecute(
  Sender: TObject);
begin
  inherited;
   if (InhDlgYesNo('Confirma a deleção de todos os pagamentos e trocos?')) then
      begin
         InhRunQuery('DELETE FROM porta_consumo_pagamento WHERE dono = ' + IntToStr(ID));
         if (PagamentoDSet.Active) then PagamentoDSet.Refresh;
         if (TrocoDSet.Active) then TrocoDSet.Refresh;
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.LimpaPortaConsumoExecute(
  Sender: TObject);
begin
  inherited;
   if (InhDlgYesNo('Confirma a deleção de todos os consumos, pagamentos e trocos?')) then
      begin
         InhRunQuery('DELETE FROM consumo WHERE dono = ' + IntToStr(ID));
         if (ConsumoDSet.Active) then ConsumoDSet.Refresh;
         InhRunQuery('DELETE FROM porta_consumo_pagamento WHERE dono = ' + IntToStr(ID));
         if (PagamentoDSet.Active) then PagamentoDSet.Refresh;
         if (TrocoDSet.Active) then TrocoDSet.Refresh;
      end;
end;

procedure TInhPortaConsumoPropriedadesDlgForm.DesfazerPagamentoFechamentoExecute(
  Sender: TObject);
begin
  inherited;
  if (InhDlgYesNo('Confirma a mudança de status, deleção de todos os pagamentos e trocos?')) then
      begin
         InhRunQuery('UPDATE porta_consumo SET status = status_anterior, status_anterior = "' +
                     PortaConsumoDSet.FieldByName('status_anterior').AsString +
                     '" WHERE id = ' + IntToStr(ID));
         InhRunQuery('DELETE FROM porta_consumo_pagamento WHERE dono = ' + IntToStr(ID));
         if (PagamentoDSet.Active) then PagamentoDSet.Refresh;
         if (TrocoDSet.Active) then TrocoDSet.Refresh;
      end;

end;

end.
