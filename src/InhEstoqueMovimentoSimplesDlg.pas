unit InhEstoqueMovimentoSimplesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QDBCtrls,
  InhDbFastLookUpDlg, InhBiblio, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS, Qt, QImgList;

type
  TInhEstoqueMovimentoSimplesDlgForm = class(TInhOkCancelDlgForm)
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
    procedure ProdutoButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeptoDbLookUpComboBoxCloseUp(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
  private
    ProdutoLookUp : TInhDbFastLookUpDlgForm;
    TipoMovimento : integer;
    function ValidateInput () : boolean;
    procedure ExecuteQuery();
  public
    { Public declarations }
  end;

procedure InhEstoqueMovimentoSimplesDlgRun (TipoMovimento : integer);

implementation

uses InhMainDM, InhDlgUtils;

{$R *.xfm}

procedure InhEstoqueMovimentoSimplesDlgRun (TipoMovimento : integer);
var
   MyForm : TInhEstoqueMovimentoSimplesDlgForm;
begin
   MyForm := TInhEstoqueMovimentoSimplesDlgForm.Create(nil);

   MyForm.TipoMovimento := TipoMovimento;

   if (TipoMovimento = ietmEntrada) then
      MyForm.Caption := MyForm.Caption + ' - Entrada'
   else if (TipoMovimento = ietmSaida) then
      MyForm.Caption := MyForm.Caption + ' - Saída';

   MyForm.DeptosDSet.Open;

   MyForm.Show;
end;

procedure TInhEstoqueMovimentoSimplesDlgForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;

   ProdutoDSet.Open;
   ProdutoLookUp := InhDbFastLookUpDlgNew (Self, ProdutoDSource, 1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOk) then
      begin
         ProdutoIDEdit.Text := ProdutoDSet.FieldByName('id').AsString;
         ProdutoDescricaoEdit.Text := ProdutoDSet.FieldByName('descricao').AsString;

         DeptoDbLookupComboBox.SetFocus;
         DeptoDbLookupComboBox.DropDown;
      end;
end;

procedure TInhEstoqueMovimentoSimplesDlgForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((FocusedControl = DeptoDbLookupComboBox) and ((Key = Key_Enter) or (Key = Key_Return))) then
      begin
         DeptoDbLookupComboBox.CloseUp(True);
         exit;
      end;

  inherited;
end;

procedure TInhEstoqueMovimentoSimplesDlgForm.DeptoDbLookUpComboBoxCloseUp(
  Sender: TObject);
begin
  inherited;
   QuantidadeEdit.SetFocus;
end;

procedure TInhEstoqueMovimentoSimplesDlgForm.ExecuteQuery;
var
   Query : TSQLDataSet;
   Departamento : string;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   if (TipoMovimento = ietmEntrada) then
      Departamento := 'departamento_destino'
   else if (TipoMovimento = ietmSaida) then
      Departamento := 'departamento_origem';

   Query.CommandText := Format ('INSERT INTO estoque_movimento_produto ' +
                                '(produto, ' + Departamento +  ', ' +
                                'quantidade, observacao, datahora, usuario) VALUES ' +
                                '(%s, %s, %s, "%s", NOW(), %s)',
                                [ProdutoIDEdit.Text,
                                 VarToStr(DeptoDbLookupComboBox.KeyValue),
                                 QuantidadeEdit.Text,
                                 ObservacoesEdit.Text,
                                 InhAccess.id]);

   Query.ExecSQL(True);
   FreeAndNil(Query);
end;

function TInhEstoqueMovimentoSimplesDlgForm.ValidateInput: boolean;
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
end;

procedure TInhEstoqueMovimentoSimplesDlgForm.OkSpeedButtonClick(
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

procedure TInhEstoqueMovimentoSimplesDlgForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   Close;
end;

end.
