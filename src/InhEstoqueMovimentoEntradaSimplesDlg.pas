unit InhEstoqueMovimentoEntradaSimplesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QDBCtrls,
  InhDbFastLookUpDlg, InhBiblio, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS, Qt, QImgList, QMask;

type
  TInhEstoqueMovimentoEntradaSimplesDlgForm = class(TInhOkCancelDlgForm)
    ProdutoButton: TButton;
    ProdutoIDEdit: TEdit;
    ProdutoDescricaoEdit: TEdit;
    DepartamentoLabel: TLabel;
    DeptoDbLookUpComboBox: TDBLookupComboBox;
    QuantidadeLabel: TLabel;
    QuantidadeEdit: TEdit;
    ObservacoesLabel: TLabel;
    ObservacoesEdit: TEdit;
    DeptosDSet: TSQLClientDataSet;
    DeptosDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    DeptosDSetid: TIntegerField;
    DeptosDSetnome: TStringField;
    ProdutoDSetid: TIntegerField;
    ProdutoDSetdescricao: TStringField;
    FornecedorButton: TButton;
    FornecedorIdEdit: TEdit;
    FornecedorNomeEdit: TEdit;
    Label1: TLabel;
    ValorEdit: TEdit;
    FornecedorDSet: TSQLClientDataSet;
    FornecedorDSource: TDataSource;
    procedure ProdutoButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeptoDbLookUpComboBoxCloseUp(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure FornecedorButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    ProdutoLookUp : TInhDbFastLookUpDlgForm;
    FornecedorLookUp : TInhDbFastLookUpDlgForm;
    function ValidateInput () : boolean;
    procedure ExecuteQuery();
  public
    { Public declarations }
  end;

procedure InhEstoqueMovimentoEntradaSimplesDlgRun ();

implementation

uses InhMainDM, InhDlgUtils;

{$R *.xfm}

procedure InhEstoqueMovimentoEntradaSimplesDlgRun ();
var
   MyForm : TInhEstoqueMovimentoEntradaSimplesDlgForm;
begin
   MyForm := TInhEstoqueMovimentoEntradaSimplesDlgForm.Create(nil);

   MyForm.DeptosDSet.Open;
   MyForm.ProdutoDSet.Open;
   MyForm.FornecedorDSet.Open;

   MyForm.Show;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;

   if (ProdutoLookUp = nil) then
      ProdutoLookUp := InhDbFastLookUpDlgNew (Self, ProdutoDSource, 1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOk) then
      begin
         ProdutoIDEdit.Text := ProdutoDSet.FieldByName('id').AsString;
         ProdutoDescricaoEdit.Text := ProdutoDSet.FieldByName('descricao').AsString;

         FornecedorButton.SetFocus;
      end;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((FocusedControl = DeptoDbLookupComboBox) and ((Key = Key_Enter) or (Key = Key_Return))) then
      begin
         DeptoDbLookupComboBox.CloseUp(True);
         exit;
      end;

  inherited;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.DeptoDbLookUpComboBoxCloseUp(
  Sender: TObject);
begin
  inherited;
   QuantidadeEdit.SetFocus;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.ExecuteQuery;
var
   Query : TSQLDataSet;
   TemFornecedor : String;
   TemValor : String;

   Fornecedor : String;
   Valor : String;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   if (Length(FornecedorIdEdit.Text) > 0) then
      begin
         TemFornecedor := 'fornecedor, ';
         Fornecedor := QuotedStr(FornecedorIdEdit.Text) + ', ';
      end;

   if (Length(ValorEdit.Text) > 0) then
      begin
         TemValor := 'valor, ';
         Valor := QuotedStr(ValorEdit.Text) + ', ';
      end;

   Query.CommandText := 'INSERT INTO estoque_movimento_produto ' +
                        '(produto, departamento_destino, quantidade, ' +

                         TemFornecedor +
                         TemValor +

                        'observacao, datahora, usuario) VALUES (' +

                        QuotedStr(ProdutoIDEdit.Text) + ', ' +
                        QuotedStr(VarToStr(DeptoDbLookupComboBox.KeyValue)) + ', ' +
                        QuotedStr(QuantidadeEdit.Text) + ', ' +

                        Fornecedor +
                        Valor +

                        QuotedStr(ObservacoesEdit.Text) + ', ' +
                        'NOW(), ' +
                        QuotedStr(InhAccess.id) + ') ';

   Query.ExecSQL(True);
   FreeAndNil(Query);
end;

function TInhEstoqueMovimentoEntradaSimplesDlgForm.ValidateInput: boolean;
begin
   Result := True;

   if (Length(ProdutoIDEdit.Text) = 0) then
      begin
         InhDlg('Um produto deve ser selecionado para este movimento. Use o botão "Produto".');
         ProdutoButton.SetFocus;
         Result := False;
         exit;
      end;

   if not (DeptoDbLookUpComboBox.KeyValue > 0) then
      begin
         Result := False;
         InhDlg('Um departamento deve ser selecionado para este movimento. Use a lista de departamentos.');
         DeptoDbLookUpComboBox.SetFocus;
         DeptoDbLookUpComboBox.DropDown;
         exit;
      end;

   if not (InhEditCheckForInt (QuantidadeEdit)) then
      begin
         Result := False;
         QuantidadeEdit.SetFocus;
         exit;
      end;

   if (Length(ValorEdit.Text) > 0) then
      if not (InhEditCheckForFloat (ValorEdit)) then
         begin
            Result := False;
            ValorEdit.SetFocus;
            exit;
         end;

end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
   if ValidateInput() then
      begin
         ExecuteQuery();
         Close;
      end
   else
      exit;

  inherited;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.FornecedorButtonClick(
  Sender: TObject);
begin
  inherited;

   if (FornecedorLookUp = nil) then
      FornecedorLookUp := InhDbFastLookUpDlgNew (Self, FornecedorDSource, 1);
   FornecedorLookUp.ShowModal;

   if (FornecedorLookUp.ModalResult = mrOk) then
      begin
         FornecedorIdEdit.Text := FornecedorDSet.FieldByName('id').AsString;
         FornecedorNomeEdit.Text := FornecedorDSet.FieldByName('nome').AsString;

         DeptoDbLookupComboBox.SetFocus;
         DeptoDbLookupComboBox.DropDown;
      end;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   Close;
end;

procedure TInhEstoqueMovimentoEntradaSimplesDlgForm.FormClose(
  Sender: TObject; var Action: TCloseAction);
begin
  inherited;

  FreeAndNil (ProdutoLookUp);
  FreeAndNil (FornecedorLookUp);

  Release;

end;

end.
