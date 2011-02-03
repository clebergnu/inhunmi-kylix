unit InhCaixaFechamento;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QMask, QDBCtrls, QStdCtrls, QGrids, QDBGrids, SqlExpr, Qt, InhBiblio, DBLocalS,
  QExtCtrls, InhLookupPadrao, InhConfig, InhReportPortaConsumo, QButtons,
  InhCaixa, InhCaixaFechamentoDM, InhCaixaTipoTrocoDlg, Math, InhReportCaixa,
  InhFiscalUtils;

type
  TInhCaixaFechamentoForm = class(TForm)
    PortaConsumosGroupBox: TGroupBox;
    CodigoLabel: TLabel;
    CodigoEdit: TEdit;
    NumeroEdit: TEdit;
    NumeroLabel: TLabel;
    PortaConsumoDBGrid: TDBGrid;
    PendenteGroupBox: TGroupBox;
    PendenteCheckBox: TCheckBox;
    ClientePendenteButton: TButton;
    PagamentoGroupBox: TGroupBox;
    PagamentoComboBox1: TDBLookupComboBox;
    PagamentoComboBox2: TDBLookupComboBox;
    PagamentoComboBox3: TDBLookupComboBox;
    PagamentoComboBox4: TDBLookupComboBox;
    PagamentoEdit2: TEdit;
    PagamentoEdit3: TEdit;
    PagamentoEdit4: TEdit;
    StatusPagamentoGroupBox: TGroupBox;
    PagamentoEdit1: TEdit;
    TotalConsumoDBEdit: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    PagoPreviamenteDBEdit: TDBEdit;
    APagarTrocoLabel: TLabel;
    Shape1: TShape;
    Label4: TLabel;
    ClientePendenteNomeEdit: TEdit;
    ClientePendenteIdEdit: TEdit;
    SendoPagoEdit: TEdit;
    APagarTrocoEdit: TEdit;
    SairSpeedButton: TSpeedButton;
    OkSpeedButton: TSpeedButton;
    CancelarSpeedButton: TSpeedButton;
    TipoComboBox: TComboBox;
    Label3: TLabel;
    AbrirPendentesButton: TButton;
    OpcoesSpeedButton: TSpeedButton;
    AtualizarSpeedButton: TSpeedButton;
    OkButton: TButton;
    procedure NumeroEditKeyPress(Sender: TObject; var Key: Char);
    procedure CodigoEditKeyPress(Sender: TObject; var Key: Char);
    procedure PortaConsumoDBGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ClientePendenteButtonClick(Sender: TObject);
    procedure PendenteCheckBoxClick(Sender: TObject);
    procedure CheckForFloat(Sender: TObject);
    procedure SairSpeedButtonClick(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NextOnEnter(Sender: TObject; var Key: Char);
    procedure PendenteCheckBoxKeyPress(Sender: TObject; var Key: Char);
    procedure AbrirPendentesButtonClick(Sender: TObject);
    procedure AtualizarSpeedButtonClick(Sender: TObject);
    procedure OpcoesSpeedButtonClick(Sender: TObject);
    procedure OnComboConfirm(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OkButtonKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    DataModule : TCaixaFechamentoDM;
  public
    procedure AdicionaPortaConsumo (PortaConsumo : String; Campo : String; Tipo : String);
    procedure AdicionaPendente (PortaConsumoID : integer);
    procedure RemovePortaConsumos (PortaConsumos : array of integer);

    procedure Clear ();
    procedure UpdateAll ();
    procedure UpdateSendoPago ();
    procedure UpdateAPagarTroco ();
    function  GetTotalConsumos () : Real;
    function  GetPagoPreviamente () : Real;
    function  GetSendoPago () : Real;
    function  GetAPagarTroco () : Real;

    procedure PagamentosCleanUp ();

    function  GetUserPayments () : TInhUserPayments;
    function  UserPaymentsCleanUp (Pagamentos : TInhUserPayments) : TInhUserPayments;
    function  UserPaymentsSort (Pagamentos : TInhUserPayments) : TInhUserPayments;
    function  UserPaymentsGetTypeOfChange (Pagamentos : TInhUserPayments) : integer;
    function  UserToDbPayments (Pagamentos : TInhUserPayments) : TInhDBPayments;

    function  GetTotalPagamentos (Pagamentos : TInhUserPayments) : real;

    function  ConfirmaTipoPagamento () : boolean;
    procedure ExecutarPagamentos (PrintToFiscal : boolean);

  end;

function CaixaFechamentoFormNew(AOWner : TComponent) : TInhCaixaFechamentoForm;

var
  PortaConsumosAFechar : array of integer;

implementation

uses
  InhMainDM, InhDlgUtils;

{$R *.xfm}

function CaixaFechamentoFormNew(AOWner : TComponent) : TInhCaixaFechamentoForm;
var
   MyForm : TInhCaixaFechamentoForm;
begin
   MyForm := TInhCaixaFechamentoForm.Create(AOWner);

   InhFormDealWithScreen (TForm(MyForm));
   MyForm.Caption := MyForm.Caption + ' (' + InhAccess.usuario + ')';

   MyForm.DataModule := CaixaFechamentoDMNew(AOwner);
   MyForm.DataModule.DMOpen();

   MyForm.Clear;

   Result := MyForm;
end;

procedure TInhCaixaFechamentoForm.AdicionaPortaConsumo (PortaConsumo : String; Campo : String; Tipo : String);
var
   UserId : String;
   Query : TSQLDataSet;
begin
   UserId := InhAccess.id;

   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   if ((Tipo = 'Todos') or (Tipo = '')) then
      Query.CommandText := 'UPDATE porta_consumo SET status_anterior = status, status = "Em Fechamento", usuario = ' + UserId + ' WHERE ' +
                            Campo + ' = ' + PortaConsumo + ' AND status = "Aberto"'
   else
      Query.CommandText := 'UPDATE porta_consumo SET status_anterior = status, status = "Em Fechamento", usuario = ' + UserId + ' WHERE ' +
                            Campo + ' = ' + PortaConsumo + ' AND tipo = "' + Tipo + '" AND status = "Aberto"';
   Query.ExecSQL(True);
   DataModule.PortaConsumoDSet.Refresh;
   Query.Free;

   UpdateAll;
end;

procedure TInhCaixaFechamentoForm.RemovePortaConsumos (PortaConsumos : array of integer);
var
   UserId : String;
   Query : TSQLDataSet;
begin
   UserId := InhAccess.id;
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := 'UPDATE porta_consumo SET status = status_anterior, status_anterior = "Em Fechamento", usuario = 0 WHERE ' +
                        'status = "Em Fechamento" AND usuario = ' + UserId + ' AND id IN (' +
                        InhArrayOfIntToStrList (PortaConsumos, ', ') + ')';
   Query.ExecSQL(True);
   Query.Free;
end;

function TInhCaixaFechamentoForm.GetTotalConsumos () : Real;
begin
   Result := 0;
   if (DataModule.TotalConsumoDSet.Active = False) then exit;
   if (DataModule.TotalConsumoDSet.RecordCount > 0) then
      Result := DataModule.TotalConsumoDSettotal.Value;
end;

function TInhCaixaFechamentoForm.GetPagoPreviamente () : Real;
begin
   Result := 0;
   if (DataModule.PagoPreviamenteDSet.Active = False) then exit;
   if (DataModule.PagoPreviamenteDSet.RecordCount > 0) then
      Result := DataModule.PagoPreviamenteDSettotal.Value;
end;

function TInhCaixaFechamentoForm.GetSendoPago () : Real;
begin
   Result := 0;

   if (PagamentoEdit1.Text <> '') then
      Result := Result + StrToFloat(PagamentoEdit1.Text);
   if (PagamentoEdit2.Text <> '') then
      Result := Result + StrToFloat(PagamentoEdit2.Text);
   if (PagamentoEdit3.Text <> '') then
      Result := Result + StrToFloat(PagamentoEdit3.Text);
   if (PagamentoEdit4.Text <> '') then
      Result := Result + StrToFloat(PagamentoEdit4.Text);
end;

function TInhCaixaFechamentoForm.GetAPagarTroco () : Real;
begin
   Result := GetTotalConsumos - GetPagoPreviamente - GetSendoPago;
end;


procedure TInhCaixaFechamentoForm.UpdateSendoPago ();
var
   SendoPago : Real;
begin
   SendoPago := GetSendoPago;

   if (SendoPago = 0) then
      SendoPagoEdit.Text := ''
   else
      SendoPagoEdit.Text := Format ('R$ %.2f', [SendoPago]);
end;

procedure TInhCaixaFechamentoForm.UpdateAPagarTroco ();
var
   APagarTroco : Real;
begin
   APagarTroco := GetApagarTroco;

   if (APagarTroco = 0) then
      begin
         APagarTrocoLabel.Caption := 'Valor Exato';
         APagarTrocoEdit.Text := 'Sem Troco';
      end
   else if (APagarTroco < 0) then
      begin
         APagarTrocoLabel.Caption := 'Troco:';
         APagarTrocoEdit.Text := Format ('R$ %.2f', [Abs(APagarTroco)]);
      end
   else
      begin
         APagarTrocoLabel.Caption := 'A Pagar:';
         APagarTrocoEdit.Text := Format ('R$ %.2f', [APagarTroco]);
      end;
end;

procedure TInhCaixaFechamentoForm.AdicionaPendente(PortaConsumoID: integer);
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'UPDATE porta_consumo SET status_anterior = status, status = "Em Fechamento", usuario = ' + InhAccess.id + ' WHERE ' +
                         'id = ' + IntToStr(PortaConsumoID) + ' AND status = "Pendente"';
   Query.ExecSQL(True);
   DataModule.PortaConsumoDSet.Refresh;
   Query.Free;

   UpdateAll;
end;


procedure TInhCaixaFechamentoForm.NumeroEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #13 then
      begin
         if (InhEditCheckForInt (NumeroEdit)) then
            begin
               AdicionaPortaConsumo (NumeroEdit.Text, 'numero', TipoComboBox.Text);
               NumeroEdit.Text := '';
            end;
      end;
end;

procedure TInhCaixaFechamentoForm.CodigoEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #13 then
      begin
         if (InhEditCheckForInt (CodigoEdit)) then
            begin
               AdicionaPortaConsumo (CodigoEdit.Text, 'id', TipoComboBox.Text);
               CodigoEdit.Text := '';
            end;
      end;
end;

procedure TInhCaixaFechamentoForm.PortaConsumoDBGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
  var DBGrid : TDBGrid;
begin
   DbGrid := TDBGrid(Sender);
  if (Shift = [ssShift]) and (Key = Key_Delete) and
     (DataModule.PortaConsumoDSet.RecordCount > 0) then
     begin
        RemovePortaConsumos ([DbGrid.DataSource.DataSet.FieldByName('id').AsInteger]);
        DBGrid.DataSource.DataSet.Refresh;
        UpdateAll;
     end;
end;

procedure TInhCaixaFechamentoForm.ClientePendenteButtonClick(Sender: TObject);
begin
   if (DataModule.ClientePendenteDSet.Active = False) then
      DataModule.ClientePendenteDSet.Open
   else
      DataModule.ClientePendenteDSet.Refresh;
   if (InhLookupFromDataSource (DataModule.ClientePendenteDSource, 'nome') <> mrOk) then
      begin
         if (ClientePendenteIdEdit.Text = '') then
            PendenteCheckBox.Checked := False;
         exit;
      end;

   ClientePendenteIdEdit.Text := DataModule.ClientePendenteDSet.FieldByName('id').AsString;
   ClientePendenteNomeEdit.Text := DataModule.ClientePendenteDSet.FieldByName('nome').AsString;
end;

procedure TInhCaixaFechamentoForm.PendenteCheckBoxClick(Sender: TObject);
begin
   if (PendenteCheckBox.Checked = True) then
      begin
         PagamentoGroupBox.Visible := False;
         UpdateAll;
         ClientePendenteButton.Enabled := True;
         ClientePendenteIdEdit.Enabled := True;
         ClientePendenteNomeEdit.Enabled := True;
         if (ClientePendenteNomeEdit.Text = '') then
            ClientePendenteButton.Click;
      end
   else
      begin
         PagamentoGroupBox.Visible := True;
         ClientePendenteButton.Enabled := False;
         ClientePendenteIdEdit.Enabled := False;
         ClientePendenteNomeEdit.Enabled := False;
      end;
end;

procedure TInhCaixaFechamentoForm.Clear ();
begin
   if (DataModule.PortaConsumoDSet.Active) then
      DataModule.PortaConsumoDSet.Refresh;

   PendenteCheckBox.Checked := False;

   ClientePendenteButton.Enabled := False;
   ClientePendenteIdEdit.Text := '';
   ClientePendenteIdEdit.Enabled := False;
   ClientePendenteNomeEdit.Text := '';
   ClientePendenteNomeEdit.Enabled := False;
   PagamentoGroupBox.Enabled := True;
   PagamentoEdit1.Text := '';
   PagamentoEdit2.Text := '';
   PagamentoEdit3.Text := '';
   PagamentoEdit4.Text := '';

   PagamentoComboBox1.KeyValue := GlobalConfig.ReadInteger('Caixa', 'FormaDePagamento1', 1);
   PagamentoComboBox2.KeyValue := GlobalConfig.ReadInteger('Caixa', 'FormaDePagamento2', 2);
   PagamentoComboBox3.KeyValue := GlobalConfig.ReadInteger('Caixa', 'FormaDePagamento3', 3);
   PagamentoComboBox4.KeyValue := GlobalConfig.ReadInteger('Caixa', 'FormaDePagamento4', 4);

   NumeroEdit.SetFocus;
end;

procedure TInhCaixaFechamentoForm.UpdateAll ();
begin
   DataModule.UpdateAll;
   UpdateSendoPago;
   UpdateAPagarTroco;
end;

procedure TInhCaixaFechamentoForm.CheckForFloat(Sender: TObject);
begin
   if (TEdit(Sender).Text <> '') then
      begin
         InhEditCheckForFloat (TEdit(Sender));
         TEdit(Sender).Text := Format ('%8.2f', [StrToFloat(TEdit(Sender).Text)]);
      end;
   UpdateSendoPago;
   UpdateAPagarTroco;
end;

procedure TInhCaixaFechamentoForm.PagamentosCleanUp ();
var
   Contador : integer;
   Mensagem : String;
   APagar : Real;
   Pago : Real;
   AlgumEliminado : boolean;

   ValorPagamento : Real;

   EditArray: array[0..3] of TEdit;
   FormaPagamentoArray : array[0..3] of TDBLookUpComboBox;
begin
   Mensagem := 'Os seguintes pagamentos serão descartados:' + #10;
   AlgumEliminado := False;

   EditArray[0] := PagamentoEdit1;
   FormaPagamentoArray[0] := PagamentoComboBox1;
   EditArray[1] := PagamentoEdit2;
   FormaPagamentoArray[1] := PagamentoComboBox2;
   EditArray[2] := PagamentoEdit3;
   FormaPagamentoArray[2] := PagamentoComboBox3;
   EditArray[3] := PagamentoEdit4;
   FormaPagamentoArray[3] := PagamentoComboBox4;

   APagar := GetTotalConsumos - GetPagoPreviamente;
   Pago := 0;
   for Contador := 0 to 3 do
      begin
         if (Pago > APagar) and (EditArray[Contador].Text <> '') then
            begin
               AlgumEliminado := True;
               ValorPagamento := StrToFloat(EditArray[Contador].Text);
               Mensagem := Mensagem + Format ('%s: R$ %-8.2f' + #10, [FormaPagamentoArray[Contador].Text,
                                                                      ValorPagamento]);
               EditArray[Contador].Text := '';
            end
         else if (Pago <= APagar) and (EditArray[Contador].Text <> '') then
            begin
               ValorPagamento := StrToFloat(EditArray[Contador].Text);
               Pago := Pago + ValorPagamento;
            end;
      end;

   if (AlgumEliminado) then
      begin
         InhDlg (Mensagem);
         UpdateAll;
      end;
end;

function TInhCaixaFechamentoForm.GetUserPayments () : TInhUserPayments;
var
   Contador : Integer;
   EditArray: array[0..3] of TEdit;
   FormaPagamentoArray : array[0..3] of TDBLookUpComboBox;
   EditAtual : TEdit;
   FormaPagamentoAtual : TDBLookUpComboBox;
begin
   EditArray[0] := PagamentoEdit1;
   FormaPagamentoArray[0] := PagamentoComboBox1;
   EditArray[1] := PagamentoEdit2;
   FormaPagamentoArray[1] := PagamentoComboBox2;
   EditArray[2] := PagamentoEdit3;
   FormaPagamentoArray[2] := PagamentoComboBox3;
   EditArray[3] := PagamentoEdit4;
   FormaPagamentoArray[3] := PagamentoComboBox4;
   SetLength (Result, 0);

   for Contador := 0 to 3 do
      begin
         EditAtual := EditArray[Contador];
         FormaPagamentoAtual := FormaPagamentoArray[Contador];
         if (EditAtual.Text <> '') then
            begin
               SetLength (Result, Length(Result) + 1);
               Result[High(Result)].FormaPagamento := FormaPagamentoAtual.KeyValue;
               Result[High(Result)].Valor := StrToFloat(EditAtual.Text);
               FormaPagamentoArray[Contador].ListSource.DataSet.Locate('id', FormaPagamentoAtual.KeyValue, []);
               Result[High(Result)].FormaPagamentoDescricao := FormaPagamentoArray[Contador].ListSource.DataSet.FieldByName('descricao').AsString;
               if (FormaPagamentoArray[Contador].ListSource.DataSet.FieldByName('tipo_troco').AsString = 'Normal') then
                  Result[High(Result)].TipoTrocoNormal := True
               else
                  Result[High(Result)].TipoTrocoNormal := False;
               end;
         end;
end;

{ REMOVE THIS WHEN FELT SAFE
function TInhCaixaFechamentoForm.GetDisponivel (Pagamentos : TInhPagamentos) : real;
var
   Contador : integer;
begin
   Result := 0;
   for Contador := Low(Pagamentos) to High(Pagamentos) do
      Result := Result + Pagamentos[Contador].Valor;
end;
}

function GetPagamentosTrocoTipo (Pagamentos : TInhUserPayments; TipoNormal: boolean) : TInhUserPayments;
var
   Contador : integer;
begin
   SetLength (Result, 0);
   for Contador := Low (Pagamentos) to High (Pagamentos) do
      begin
      if Pagamentos[Contador].TipoTrocoNormal = TipoNormal then
         begin
            SetLength(Result, Length(Result) + 1);
            Result[High(Result)] := Pagamentos[Contador];
         end;
      end;
end;

function  TInhCaixaFechamentoForm.GetTotalPagamentos (Pagamentos : TInhUserPayments) : real;
var
   Contador : integer;
begin
   Result := 0;
   for Contador := Low(Pagamentos) to High(Pagamentos) do
      Result := Result + Pagamentos[Contador].Valor;
end;

function  TInhCaixaFechamentoForm.UserPaymentsGetTypeOfChange (Pagamentos : TInhUserPayments) : integer;
var
   SendoPagoTrocoNormal : real;
   Troco : real;
begin
   Result := 0;
   Troco := Abs(GetAPagarTroco);
   SendoPagoTrocoNormal := GetTotalPagamentos (GetPagamentosTrocoTipo (Pagamentos, True));

   if (Troco > SendoPagoTrocoNormal) then
      Result := InhCaixaTipoTrocoDlgRun();
end;

function TInhCaixaFechamentoForm.UserPaymentsCleanUp (Pagamentos : TInhUserPayments) : TInhUserPayments;
var
   Contador : integer;
   Mensagem : String;
   APagar : Real;
   Pago : Real;
   AlgumEliminado : boolean;
begin
   Mensagem := 'Os seguintes pagamentos serão descartados:' + #10;
   AlgumEliminado := False;
   SetLength (Result, 0);

   APagar := GetTotalConsumos - GetPagoPreviamente;
   Pago := 0;
   for Contador := Low(Pagamentos) to High(Pagamentos) do
      begin
         if (Pago >= APagar) then
            begin
               AlgumEliminado := True;
               Mensagem := Mensagem + Format ('%s: R$ %-8.2f' + #10, [Pagamentos[Contador].FormaPagamentoDescricao,
                                                                         Pagamentos[Contador].Valor]);
            end
         else
            begin
               SetLength (Result, Length(Result) + 1);
               Result[High(Result)] := Pagamentos[Contador];
            end;
         Pago := Pago + Pagamentos[Contador].Valor;
      end;
   if (AlgumEliminado) then InhDlg (Mensagem);
end;

function TInhCaixaFechamentoForm.UserPaymentsSort (Pagamentos : TInhUserPayments) : TInhUserPayments;
var
   Contador : integer;
begin
   SetLength (Result, 0);

   // Primeiro os TipoTrocoNormal = False
   for Contador := Low(Pagamentos) to High(Pagamentos) do
      if not (Pagamentos[Contador].TipoTrocoNormal) then
        begin
           SetLength (Result, Length(Result) + 1);
           Result[High(Result)] := Pagamentos[Contador];
        end;

   // Agora os TipoTrocoNormal = True
   for Contador := Low(Pagamentos) to High(Pagamentos) do
      if (Pagamentos[Contador].TipoTrocoNormal) then
        begin
           SetLength (Result, Length(Result) + 1);
           Result[High(Result)] := Pagamentos[Contador];
        end;
end;

function TInhCaixaFechamentoForm.UserToDbPayments (Pagamentos : TInhUserPayments) : TInhDBPayments;
var
   ValorTotalPortaConsumoAtual : Currency;
   ValorRestantePortaConsumoAtual : Currency;

   ValorDisponivelAtual : Currency;

   ValorPagamentoAtual : Currency;

   Contador : integer;
   TipoTroco : integer;
begin
   SetLength (Result, 0);
   SetLength (PortaConsumosAFechar, 0);

   ValorTotalPortaConsumoAtual := 0;
   ValorRestantePortaConsumoAtual := 0;


   TipoTroco := UserPaymentsGetTypeOfChange (Pagamentos);

   DataModule.PortaConsumoDSet.First;
   Contador := 0;
   ValorDisponivelAtual := Pagamentos[Contador].Valor;
   while not (DataModule.PortaConsumoDSet.Eof) do
      begin
         if (ValorTotalPortaConsumoAtual = 0) then
            begin
               ValorTotalPortaConsumoAtual := DataModule.PortaConsumoDSet.FieldByName('total_consumos').AsFloat  -
                                              DataModule.PortaConsumoDSet.FieldByName('total_pagamentos').AsFloat;
               ValorRestantePortaConsumoAtual := ValorTotalPortaConsumoAtual;
            end;

         if (ValorDisponivelAtual = 0) then
            begin
               Inc(Contador);
               ValorDisponivelAtual := Pagamentos[Contador].Valor;
            end;

         while (ValorDisponivelAtual > 0) and (ValorRestantePortaConsumoAtual > 0) do
            begin
               ValorPagamentoAtual := Min(ValorRestantePortaConsumoAtual, ValorDisponivelAtual);

               // Cria Novo Pagamento
               SetLength (Result, Length(Result) + 1);
               Result[High(Result)].PortaConsumo := DataModule.PortaConsumoDSet.FieldByName('id').AsInteger;
               Result[High(Result)].FormaPagamento := Pagamentos[Contador].FormaPagamento;
               Result[High(Result)].Valor := ValorPagamentoAtual;

               // Faz esses valores serem reconhecidos
               ValorDisponivelAtual := ValorDisponivelAtual - ValorPagamentoAtual;
               ValorRestantePortaConsumoAtual := ValorRestantePortaConsumoAtual - ValorPagamentoAtual;
            end;
         if (ValorRestantePortaConsumoAtual = 0) then
            begin
               // Adiciona este porta consumo a lista de porta consumos a fechar
               SetLength (PortaConsumosAFechar, Length(PortaConsumosAFechar) + 1);
               PortaConsumosAFechar[High(PortaConsumosAFechar)] := DataModule.PortaConsumoDSet.FieldByName('id').AsInteger;
               //
               ValorTotalPortaConsumoAtual := 0;
               DataModule.PortaConsumoDSet.Next;
            end;
      end;

   if (ValorDisponivelAtual > 0) then
      begin
         if TipoTroco <> 0 then
            begin
               DataModule.FormaPagamentoDSet.Locate('id', TipoTroco, []);
               if (DataModule.FormaPagamentoDSet.FieldByName('tipo_contra_vale').AsString = 'Sim') then
                  begin
                     InhReportContraVale (ValorDisponivelAtual);
                  end;
            end
         else
            TipoTroco := Pagamentos[Contador].FormaPagamento;
         //Adicionar valor do troco ao ultimo pagamamento
         Result[High(Result)].Valor := Result[High(Result)].Valor + ValorDisponivelAtual;

         //Adicionar registro do troco
         SetLength (Result, Length(Result) + 1);
         Result[High(Result)].PortaConsumo := DataModule.PortaConsumoDSet.FieldByName('id').AsInteger;
         Result[High(Result)].FormaPagamento := TipoTroco;
         Result[High(Result)].Valor := - ValorDisponivelAtual;
      end;
end;

function TInhCaixaFechamentoForm.ConfirmaTipoPagamento () : boolean;
var
   ValorAPagarTroco : Real;
   ValorRestanteAPagarTroco : Real;
begin
   Result := False;
   // Verifica o tipo de Pagamento/Fechamento a se realizar, dependedo
   // do ValorAPagarTroco / ValorRestante (= APagar - SendoPago)
   ValorAPagarTroco := GetTotalConsumos - GetPagoPreviamente;
   ValorRestanteAPagarTroco := ValorAPagarTroco - GetSendoPago;

   if (ValorRestanteAPagarTroco > 0) then
      if (not InhDlgYesNo ('O valor sendo pago não é suficiente para o fechamento de' + #10 +
                          'todos os Porta-Consumos selecionados. Deseja continuar e' + #10 +
                          'fechar os Porta-Consumos possíveis e/ou realizar um'  + #10 +
                          'pagamento parcial?')) then exit;

   Result := True;
end;

procedure TInhCaixaFechamentoForm.ExecutarPagamentos (PrintToFiscal : boolean);
var
   PagamentosUsuario : TInhUserPayments;
   PagamentosAExecutar : TInhDBPayments;
begin
   SetLength (PagamentosAExecutar, 0);
   // Pega pagamentos conforme digitado pelo usuario
   PagamentosUsuario := GetUserPayments();

   if (Length(PagamentosUsuario) > 0) then
      begin
         PagamentosUsuario := UserPaymentsSort (PagamentosUsuario);
         PagamentosAExecutar := UserToDBPayments (PagamentosUsuario);

         if (DataModule.ExecutarPagamentos(PagamentosAExecutar)) then
            begin
               DataModule.ExecutarFechamento(PortaConsumosAFechar);

               if (PrintToFiscal = True) then
                  begin
                  InhFiscalQueueCoupon(CouponArray(PortaConsumosAFechar));
                  end
               else
                  begin
                  InhReportPortaConsumoFechamento(PortaConsumosAFechar);
                  end
            end;
      end;
end;

procedure TInhCaixaFechamentoForm.SairSpeedButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TInhCaixaFechamentoForm.OkSpeedButtonClick(Sender: TObject);
begin
{
   if (DataModule.PortaConsumoDSet.RecordCount = 0) then
      begin
         InhDlg ('Não há Porta-Consumos a serem fechados.');
         Clear;
         exit;
      end;

   if (RoundTo(GetAPagarTroco(), -2) > 0) and (not PendenteCheckBox.Checked) then
      begin
         InhDlg ('Valor insuficiente para o fechamento dos Porta-Consumos selecionados.');
         PagamentoEdit1.SetFocus;
         Exit;
      end;

   if (PendenteCheckBox.Checked) then
      if (ClientePendenteIdEdit.Text <> '') and (ClientePendenteNomeEdit.Text <> '') then
         begin
            DataModule.FecharPendente(ClientePendenteIdEdit.Text);
            InhReportPortaConsumoPendente (InhDataSetFieldToArrayOfInt(TSQLDataSet(DataModule.PortaConsumoDSet), 'id'),
                                           ClientePendenteNomeEdit.Text);
            Clear;
            UpdateAll;
            exit;
         end
      else
         begin
            InhDlg ('Selecione um cliente pendente para este pagamento');
            exit;
         end;

   PagamentosCleanUp ();
   ExecutarPagamentos(True);
   DataModule.PortaConsumoDSet.Refresh;
   Clear();
   UpdateAll();
}
end;

procedure TInhCaixaFechamentoForm.CancelarSpeedButtonClick(Sender: TObject);
var
   PortaConsumos : TInhArrayOfInteger;
begin
   PortaConsumos := nil;
   if (DataModule.PortaConsumoDSet.RecordCount > 0) then
      begin
         PortaConsumos := InhDataSetFieldToArrayOfInt (TSQLDataSet(DataModule.PortaConsumoDSet), 'id');
         RemovePortaConsumos(PortaConsumos);
         Clear;
         UpdateAll;
      end;
end;


procedure TInhCaixaFechamentoForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if Shift = [ssCtrl] then
      case Key of
         Key_1:
            begin
               FocusControl(PagamentoComboBox1);
               PagamentoComboBox1.DropDown;
            end;
         Key_2:
            begin
               FocusControl(PagamentoComboBox2);
               PagamentoComboBox2.DropDown;
            end;
         Key_3:
            begin
               FocusControl(PagamentoComboBox3);
               PagamentoComboBox3.DropDown;
            end;
         Key_4:
            begin
               FocusControl(PagamentoComboBox4);
               PagamentoComboBox4.DropDown;
            end;
      end
   else if Shift = [ssAlt] then
      case Key of
         Key_1: PagamentoEdit1.SetFocus;
         Key_2: PagamentoEdit2.SetFocus;
         Key_3: PagamentoEdit3.SetFocus;
         Key_4: PagamentoEdit4.SetFocus;
      end;
   if (Shift = [ssCtrl]) or (Shift = [ssAlt]) then
      Key := 0;
end;

procedure TInhCaixaFechamentoForm.NextOnEnter(Sender: TObject;
  var Key: Char);
var
   Widget : TWidgetControl;
begin
   if (Key = #13) then
      begin
         Widget := FindNextControl(TWidgetControl(Sender), True, True, False);
         FocusControl(Widget);
      end;
end;

procedure TInhCaixaFechamentoForm.PendenteCheckBoxKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #13) then
      OkSpeedButton.Click;
end;

procedure TInhCaixaFechamentoForm.AbrirPendentesButtonClick(Sender: TObject);
begin
   if (DataModule.PendentesDSet.Active = True) then
      DataModule.PendentesDSet.Close;

   DataModule.PendentesDSet.Open;

   if(InhLookupFromDataSource(DataModule.PendentesDSource, 'nome') = mrOk) then
      AdicionaPendente (DataModule.PendentesDSet.FieldByName('id').AsInteger);
end;

procedure TInhCaixaFechamentoForm.AtualizarSpeedButtonClick(
  Sender: TObject);
begin
   UpdateAll;
end;

procedure TInhCaixaFechamentoForm.OpcoesSpeedButtonClick(Sender: TObject);
begin
   InhDlgNotImplemented();
end;

procedure TInhCaixaFechamentoForm.OnComboConfirm(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((Key = Key_Enter) or (Key = Key_Return) or (Key = Key_Tab)) then
      begin
         TDBLookUpComboBox(Sender).CloseUp(True);

         case TControl(Sender).Tag of
            1 : FocusControl(PagamentoEdit1);
            2 : FocusControl(PagamentoEdit2);
            3 : FocusControl(PagamentoEdit3);
            4 : FocusControl(PagamentoEdit4);
         end;
      end;
end;

procedure TInhCaixaFechamentoForm.OkButtonKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
   PrintToFiscal : boolean ;
begin
   if (Shift = [ssShift]) and ((Key = Key_Enter) or (Key = Key_Return)) then
      begin
         PrintToFiscal := False;
      end
   else if ((Key = Key_Enter) or (Key = Key_Return)) then
      begin
         PrintToFiscal := True;
      end
   else
      exit;

   if (DataModule.PortaConsumoDSet.RecordCount = 0) then
      begin
         InhDlg ('Não há Porta-Consumos a serem fechados.');
         Clear;
         exit;
      end;

   if (RoundTo(GetAPagarTroco(), -2) > 0) and (not PendenteCheckBox.Checked) then
      begin
         InhDlg ('Valor insuficiente para o fechamento dos Porta-Consumos selecionados.');
         PagamentoEdit1.SetFocus;
         Exit;
      end;

   if (PendenteCheckBox.Checked) then
      if (ClientePendenteIdEdit.Text <> '') and (ClientePendenteNomeEdit.Text <> '') then
         begin
            DataModule.FecharPendente(ClientePendenteIdEdit.Text);
            InhReportPortaConsumoPendente (InhDataSetFieldToArrayOfInt(TSQLDataSet(DataModule.PortaConsumoDSet), 'id'),
                                           ClientePendenteNomeEdit.Text);
            Clear;
            UpdateAll;
            exit;
         end
      else
         begin
            InhDlg ('Selecione um cliente pendente para este pagamento');
            exit;
         end;

   PagamentosCleanUp ();
   ExecutarPagamentos(PrintToFiscal);
   DataModule.PortaConsumoDSet.Refresh;
   Clear();
   UpdateAll();
end;

end.
