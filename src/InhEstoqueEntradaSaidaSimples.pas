unit InhEstoqueEntradaSaidaSimples;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhDbFastLookUpDlg, InhBiblio, InhDlgUtils,
  InhEstoqueEntradaSaidaSimplesDM;

type
  TInhEstoqueEntradaSaidaSimplesForm = class(TInhDbForm)
    IDLabel: TLabel;
    IDDbEdit: TDBEdit;
    DepartamentoLabel: TLabel;
    ProdutoIDDbEdit: TDBEdit;
    ProdutoDbEdit: TDBEdit;
    ProdutoButton: TButton;
    QuantidadeDbEdit: TDBEdit;
    QuantidadeLabel: TLabel;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    DBLookupComboBox1: TDBLookupComboBox;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    ObservacaoDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    procedure MasterDataSetAfterScroll (DataSet : TDataSet);
    procedure FormShow(Sender: TObject);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
  private
     ProdutoLookUp : TInhDbFastLookUpDlgForm;
    { Private declarations }
  public
    { Public declarations }
  end;

function EstoqueEntradaSaidaFormNew(TipoMovimento : TInhEstoqueTipoMovimento) : TInhEstoqueEntradaSaidaSimplesForm;

implementation

uses InhEstoqueMovimentoEntradaDM;

{$R *.xfm}

function EstoqueEntradaSaidaFormNew(TipoMovimento : TInhEstoqueTipoMovimento) : TInhEstoqueEntradaSaidaSimplesForm;
var
   MyForm : TInhEstoqueEntradaSaidaSimplesForm;
begin
   MyForm := TInhEstoqueEntradaSaidaSimplesForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := EstoqueEntradaSaidaSimplesDMNew(TipoMovimento);

   case TipoMovimento of
      ietmEntrada :
         with MyForm do
            begin
               Caption := Caption + 'Entradas Simples';
               HelpTopic := 'capitulo_cadastro_estoque_entrada_simples';
            end;
      ietmSaida :
         with MyForm do
            begin
               Caption := Caption + 'Saídas Simples';
               HelpTopic := 'capitulo_cadastro_estoque_saida_simples';
            end;
   end;

   TEstoqueEntradaSaidaSimplesDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueEntradaSaidaSimplesDM(MyForm.DataModule).MovimentoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.ProdutoButton;

   Result := MyForm;
end;

procedure TInhEstoqueEntradaSaidaSimplesForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueEntradaSaidaSimplesDM(DataModule).DMOpen;
end;

procedure TInhEstoqueEntradaSaidaSimplesForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueEntradaSaidaSimplesForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;
  if (ProdutoLookUp = nil) then
      ProdutoLookUp := InhDbFastLookUpDlgNew (Self,
                                              TEstoqueEntradaSaidaSimplesDM(DataModule).ProdutoDSource,
                                              1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueEntradaSaidaSimplesDM(DataModule) do
            begin
               MovimentoDSet.Edit;
               MovimentoDSet.FieldByName('produto').Value := ProdutoDSet.FieldByName('id').Value;
            end;
      end;
end;

procedure TInhEstoqueEntradaSaidaSimplesForm.MasterDataSetBeforePost(
  DataSet: TDataSet);
begin
   with DataSet do
      begin
         if (State = dsInsert) then
            begin
               FieldByName('usuario').AsString := InhAccess.id;
               FieldByName('datahora').AsDateTime := Now();
               Tag := 111
            end;
      end;
end;

end.
