unit InhEstoqueTranferenciaSimplesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QMask, QDBCtrls,
  Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, Qt,
  InhDbFastLookUpDlg, InhDlgUtils, InhBiblio;

type
  TInhEstoqueTransferenciaSimplesDlgForm = class(TInhOkCancelDlgForm)
    ProdutoButton: TButton;
    DeptoOrigemLabel: TLabel;
    DeptoDestinoLabel: TLabel;
    DeptoOrigemDbLookupComboBox: TDBLookupComboBox;
    DeptoDestinoDbLookupComboBox: TDBLookupComboBox;
    QuantidadeLabel: TLabel;
    QuantidadeEdit: TEdit;
    ObservacoesLabel: TLabel;
    ObservacoesEdit: TEdit;
    DeptosDSet: TSQLClientDataSet;
    DeptoOrigemDSource: TDataSource;
    DeptoDestinoDSource: TDataSource;
    ProdutoDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSetid: TIntegerField;
    ProdutoDSetdescricao: TStringField;
    ProdutoIDEdit: TEdit;
    ProdutoDescricaoEdit: TEdit;
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure DeptoOrigemDbLookupComboBoxCloseUp(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeptoDestinoDbLookupComboBoxCloseUp(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
  private
    ProdutoLookUp : TInhDbFastLookUpDlgForm;
    function ValidateInput () : boolean;
    procedure ExecuteQuery();
  public
    { Public declarations }
  end;

procedure InhEstoqueTransferenciaSimplesDlgRun ();

implementation

uses InhMainDM;

{$R *.xfm}


procedure InhEstoqueTransferenciaSimplesDlgRun ();
var
   MyForm : TInhEstoqueTransferenciaSimplesDlgForm;
begin
   MyForm := TInhEstoqueTransferenciaSimplesDlgForm.Create(nil);

   MyForm.DeptosDSet.Open;

   MyForm.Show;
end;


procedure TInhEstoqueTransferenciaSimplesDlgForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   Close;
end;

procedure TInhEstoqueTransferenciaSimplesDlgForm.ProdutoButtonClick(
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

         DeptoOrigemDbLookupComboBox.SetFocus;
         DeptoOrigemDbLookupComboBox.DropDown;
      end;

end;

procedure TInhEstoqueTransferenciaSimplesDlgForm.DeptoOrigemDbLookupComboBoxCloseUp(
  Sender: TObject);
begin
  inherited;
   DeptoDestinoDbLookupComboBox.SetFocus;
   DeptoDestinoDbLookupComboBox.DropDown;
end;

procedure TInhEstoqueTransferenciaSimplesDlgForm.FormKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if ((FocusedControl = DeptoOrigemDbLookupComboBox) and ((Key = Key_Enter) or (Key = Key_Return))) then
      begin
         DeptoOrigemDbLookupComboBox.CloseUp(True);
         exit;
      end
   else if ((FocusedControl = DeptoDestinoDbLookupComboBox) and ((Key = Key_Enter) or (Key = Key_Return))) then
      begin
         DeptoDestinoDbLookupComboBox.CloseUp(True);
         exit;
      end;

  inherited;
end;

procedure TInhEstoqueTransferenciaSimplesDlgForm.DeptoDestinoDbLookupComboBoxCloseUp(
  Sender: TObject);
begin
  inherited;
   QuantidadeEdit.SetFocus;
end;

procedure TInhEstoqueTransferenciaSimplesDlgForm.ExecuteQuery;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := Format ('INSERT INTO estoque_movimento_produto ' +
                                '(produto, departamento_origem, departamento_destino, ' +
                                'quantidade, observacao, datahora, usuario) VALUES ' +
                                '(%s, %s, %s, %s, "%s", NOW(), %s)',
                                [ProdutoIDEdit.Text,
                                 VarToStr(DeptoOrigemDbLookupComboBox.KeyValue),
                                 VarToStr(DeptoDestinoDbLookupComboBox.KeyValue),
                                 QuantidadeEdit.Text,
                                 ObservacoesEdit.Text,
                                 InhAccess.id]);

   Query.ExecSQL(True);
   FreeAndNil(Query);
end;

function TInhEstoqueTransferenciaSimplesDlgForm.ValidateInput: boolean;
begin
   Result := True;

   if (Length(ProdutoIDEdit.Text) = 0) then
      begin
         InhDlg('Um produto deve ser selecionado para esta transferência. Use o botão "Produto".');
         ProdutoButton.SetFocus;
         Result := False;
         exit;
      end;

   if not (DeptoOrigemDbLookUpComboBox.KeyValue > 0) then
      begin
         Result := False;
         InhDlg('Um departamento origem deve ser selecionado para este movimento. Use a lista de departamentos.');
         DeptoOrigemDbLookUpComboBox.SetFocus;
         DeptoOrigemDbLookUpComboBox.DropDown;
         exit;
      end;

   if not (DeptoDestinoDbLookUpComboBox.KeyValue > 0) then
      begin
         Result := False;
         InhDlg('Um departamento destino deve ser selecionado para este movimento. Use a lista de departamentos.');
         DeptoDestinoDbLookUpComboBox.SetFocus;
         DeptoDestinoDbLookUpComboBox.DropDown;
         exit;
      end;

   if not (InhEditCheckForInt (QuantidadeEdit)) then
      begin
         Result := False;
         QuantidadeEdit.SetFocus;
         exit;
      end;

end;

procedure TInhEstoqueTransferenciaSimplesDlgForm.OkSpeedButtonClick(
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

end.
