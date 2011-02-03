unit InhEstoqueMovimentoSaidaSimplesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QDBCtrls,
  InhDbFastLookUpDlg, InhBiblio, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS, Qt, QImgList, QMask;

type
  TInhEstoqueMovimentoSaidaSimplesDlgForm = class(TInhOkCancelDlgForm)
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

procedure InhEstoqueMovimentoSaidaSimplesDlgRun ();

implementation

uses InhMainDM, InhDlgUtils;

{$R *.xfm}

procedure InhEstoqueMovimentoSaidaSimplesDlgRun ();
var
   MyForm : TInhEstoqueMovimentoSaidaSimplesDlgForm;
begin
   MyForm := TInhEstoqueMovimentoSaidaSimplesDlgForm.Create(nil);

   MyForm.DeptosDSet.Open;

   MyForm.Show;
end;

procedure TInhEstoqueMovimentoSaidaSimplesDlgForm.ProdutoButtonClick(
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

procedure TInhEstoqueMovimentoSaidaSimplesDlgForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((FocusedControl = DeptoDbLookupComboBox) and ((Key = Key_Enter) or (Key = Key_Return))) then
      begin
         DeptoDbLookupComboBox.CloseUp(True);
         exit;
      end;

  inherited;
end;

procedure TInhEstoqueMovimentoSaidaSimplesDlgForm.DeptoDbLookUpComboBoxCloseUp(
  Sender: TObject);
begin
  inherited;
   QuantidadeEdit.SetFocus;
end;

procedure TInhEstoqueMovimentoSaidaSimplesDlgForm.ExecuteQuery;
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

function TInhEstoqueMovimentoSaidaSimplesDlgForm.ValidateInput: boolean;
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

procedure TInhEstoqueMovimentoSaidaSimplesDlgForm.OkSpeedButtonClick(
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

procedure TInhEstoqueMovimentoSaidaSimplesDlgForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   Close;
end;

end.
