unit InhEstoqueAjusteSimplesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhOkCancelDlg, Provider, SqlExpr, DB, DBClient,
  DBLocal, DBLocalS, QDBCtrls, QExtCtrls, QButtons, Qt,
  InhDlgUtils, InhDbFastLookupDlg, InhBiblio;

type
  TInhEstoqueAjusteSimplesDlgForm = class(TInhOkCancelDlgForm)
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
    DeptosDSetid: TIntegerField;
    DeptosDSetnome: TStringField;
    DeptosDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSetid: TIntegerField;
    ProdutoDSetdescricao: TStringField;
    ProdutoDSource: TDataSource;
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    ProdutoLookUp : TInhDbFastLookUpDlgForm;
    function ValidateInput () : boolean;
    procedure ExecuteQuery();
  public
    { Public declarations }
  end;

procedure InhEstoqueAjusteSimplesDlgRun ();

implementation

uses InhMainDM;

{$R *.xfm}

{ TInhEstoqueAjusteSimplesDlgForm }

procedure InhEstoqueAjusteSimplesDlgRun ();
var
   MyForm : TInhEstoqueAjusteSimplesDlgForm;
begin
   MyForm := TInhEstoqueAjusteSimplesDlgForm.Create(nil);

   MyForm.DeptosDSet.Open;

   MyForm.Show;
end;

function TInhEstoqueAjusteSimplesDlgForm.ValidateInput: boolean;
begin
   Result := True;

   if (Length(ProdutoIDEdit.Text) = 0) then
      begin
         InhDlg('Um produto deve ser selecionado para este ajuste. Use o botão "Produto".');
         ProdutoButton.SetFocus;
         Result := False;
         exit;
      end;

   if not (DeptoDbLookUpComboBox.KeyValue > 0) then
      begin
         Result := False;
         InhDlg('Um departamento deve ser selecionado para este ajuste. Use a lista de departamentos.');
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

procedure TInhEstoqueAjusteSimplesDlgForm.ExecuteQuery;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := Format ('INSERT INTO estoque_ajuste_produto ' +
                                '(produto, departamento, ' +
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

procedure TInhEstoqueAjusteSimplesDlgForm.OkSpeedButtonClick(
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

procedure TInhEstoqueAjusteSimplesDlgForm.ProdutoButtonClick(
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

procedure TInhEstoqueAjusteSimplesDlgForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   Close;
end;

procedure TInhEstoqueAjusteSimplesDlgForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
   if ((FocusedControl = DeptoDbLookupComboBox) and ((Key = Key_Enter) or (Key = Key_Return))) then
      begin
         DeptoDbLookupComboBox.CloseUp(True);
         exit;
      end
end;

end.
