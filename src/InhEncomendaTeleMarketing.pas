unit InhEncomendaTeleMarketing;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QGrids, QDBGrids, QStdCtrls, QExtCtrls, QComCtrls, QDBCtrls, InhBiblio,
  QMask, QButtons, Qt, QTypes,

  InhEncomendaTeleMarketingDM, InhDbGridUtils, InhLookUpPadrao,
  InhEncomendaTeleMarketingImpressaoDlg, InhStringResources;

type
  TInhEncomendaTeleMarketingForm = class(TForm)
    ClienteGroupBox: TGroupBox;
    TelefoneLabel: TLabel;
    TelefoneEdit: TEdit;
    ClienteDbLookupComboBox: TDBLookupComboBox;
    ClienteLabel: TLabel;
    EntregaGroupBox: TGroupBox;
    EnderecoButton: TButton;
    EnderecoDbMemo: TDBMemo;
    Label1: TLabel;
    DataHoraEntregaDbEdit: TDBEdit;
    TipoEntregaDbCheckBox: TDBCheckBox;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    CancelarSpeedButton: TSpeedButton;
    OkSpeedButton: TSpeedButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ProdutosDbGrid: TDBGrid;
    TabSheet2: TTabSheet;
    SairSpeedButton: TSpeedButton;
    StatusBar: TStatusBar;
    Label3: TLabel;
    DBEdit1: TDBEdit;
    DBMemo1: TDBMemo;
    Label4: TLabel;
    procedure TelefoneEditExit(Sender: TObject);
    procedure ClienteDbLookupComboBoxKeyPress(Sender: TObject;
      var Key: Char);
    procedure ClienteDbLookupComboBoxExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SairSpeedButtonClick(Sender: TObject);
    procedure EnderecoDbMemoExit(Sender: TObject);
    procedure ProdutosDbGridEditButtonClick(Sender: TObject);
    procedure ProdutosDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure EnderecoButtonClick(Sender: TObject);
  private
    EncomendaAtiva : boolean; {Define se uma encomenda ja esta em processamento}
    EncomendaCriada : boolean; {Define se os registros de Porta-Consumo / Encomenda
                                já foram criados}


    DataModule : TEncomendaTeleMarketingDM;
    procedure PrepararParaNovaEncomenda (); // Prepara a tela para uma nova encomenda
    procedure EncomendaCriaNova ();
    procedure ClienteSelecionado (PessoaInstituicaoId : Integer);
    procedure PrepararParaAdicionarProdutos ();
  end;

function EncomendaTeleMarketingFormNew(AOwner : TComponent) : TInhEncomendaTeleMarketingForm;

implementation

uses
   DB,
   InhMain, InhDbForm, InhPessoa, InhPortaConsumoUtils, InhDlgUtils, InhEncomendaUtils,
   InhEncomendaTeleMarketingPessoaCadastro;

{$R *.xfm}

function EncomendaTeleMarketingFormNew(AOwner : TComponent) : TInhEncomendaTeleMarketingForm;
var
   MyForm : TInhEncomendaTeleMarketingForm;
begin
   MyForm := TInhEncomendaTeleMarketingForm.Create(AOwner);

   MyForm.DataModule := TEncomendaTeleMarketingDM.Create(AOwner);

   Result := MyForm;
end;

procedure TInhEncomendaTeleMarketingForm.TelefoneEditExit(Sender: TObject);
begin
   if (Trim(TEdit(Sender).Text) = '') then
      begin
         TEdit(Sender).SetFocus;
         InhDlg(InhStrTeleMarketingTelephoneNumber);
         exit;
      end;

   if (DataModule.ClienteDSet.Active) then
      DataModule.ClienteDSet.Close;

   DataModule.ClienteDSet.Params[0].Value := TEdit(Sender).Text;
   DataModule.ClienteDSet.Open;

   if (DataModule.ClienteDSet.RecordCount = 1) then
      begin
         ClienteDBLookUpComboBox.KeyValue := DataModule.ClienteDSet.FieldByName('id').AsInteger;
         ClienteSelecionado (DataModule.ClienteDSet.FieldByName('id').AsInteger);
      end


   else if (DataModule.ClienteDSet.RecordCount > 1) then
      begin
         ClienteDBLookUpComboBox.DropDown;
         StatusBar.SimpleText := InhStrTeleMarketingCustomersListed
      end

   else if(InhDlgYesNo ('Este telefone não pertence a nenhum cliente '+
                        'cadastrado. Deseja abrir a tela de clientes '+
                        'para adicionar este cliente?') = True) then
      begin
         InhMainForm.AbrirPessoaExecute(TObject(Self));
         TInhDbForm(PessoaForm).MasterDataSource.DataSet.Insert;
      end;


end;

procedure TInhEncomendaTeleMarketingForm.ClienteDbLookupComboBoxKeyPress(
  Sender: TObject; var Key: Char);
begin
   if (Key = #13) then
      begin
         TDBLookUpComboBox(Sender).CloseUp(True);
         ClienteSelecionado(DataModule.ClienteDSet.Fieldbyname('id').AsInteger);
      end;
end;

procedure TInhEncomendaTeleMarketingForm.ClienteDbLookupComboBoxExit(
  Sender: TObject);
begin
   if (DataModule.ClienteDSet.FieldByName('id').AsInteger <> 0) then
      ClienteSelecionado(DataModule.ClienteDSet.FieldByName('id').AsInteger)
   else
      begin
         TelefoneEdit.Text := '';
         TelefoneEdit.SetFocus;
      end;
end;

procedure TInhEncomendaTeleMarketingForm.ClienteSelecionado(
  PessoaInstituicaoId: Integer);
begin
   DataModule.ClienteSelecionado(PessoaInstituicaoID);
   if not EncomendaCriada then
      begin
         EncomendaCriaNova();
         StatusBar.SimpleText := InhStrTeleMarketingCustomerSelected;
      end;
   DataHoraEntregaDbEdit.SetFocus;
end;

procedure TInhEncomendaTeleMarketingForm.PrepararParaNovaEncomenda;
begin
   DataModule.DMClose;

   EncomendaAtiva  := False;
   EncomendaCriada := False;

   PageControl1.ActivePageIndex := 0;

   StatusBar.SimpleText := InhStrTeleMarketingTelephoneNumber;
   TelefoneEdit.Text := '';
   TelefoneEdit.SetFocus;
end;

procedure TInhEncomendaTeleMarketingForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   // Default action is to hide the form
   Action := caHide;
   if EncomendaAtiva then
      // Give the user a chance to save its work
      if not (InhDlgYesNo ('Esta encomenda ainda não foi salva. Deseja realmente sair e abandonar as alterações?')) then
         Action := caNone;
end;

procedure TInhEncomendaTeleMarketingForm.FormCreate(Sender: TObject);
begin
   EncomendaAtiva := False;
end;

procedure TInhEncomendaTeleMarketingForm.FormShow(Sender: TObject);
begin
   if not EncomendaAtiva then PrepararParaNovaEncomenda();
end;

procedure TInhEncomendaTeleMarketingForm.SairSpeedButtonClick(
  Sender: TObject);
begin
   Close;
end;

procedure TInhEncomendaTeleMarketingForm.EncomendaCriaNova;
begin
   if not EncomendaCriada then
      begin
          InhPortaConsumoNovo (itpEncomenda,
                               DataModule.ClienteDSet.Fieldbyname('id').AsInteger,
                               0,
                               StrToInt(InhAccess.Id));
          DataModule.PortaConsumoDSet.Params[0].Value := InhAccess.id;
          DataModule.PortaConsumoDSet.Open;
          DataModule.CriarEncomenda;
          EncomendaAtiva := True;
          EncomendaCriada := True;
       end;
end;

procedure TInhEncomendaTeleMarketingForm.EnderecoDbMemoExit(
  Sender: TObject);
begin
   PrepararParaAdicionarProdutos;
end;

procedure TInhEncomendaTeleMarketingForm.PrepararParaAdicionarProdutos;
begin
   DataModule.AbrirConsumos;
   ProdutosDbGrid.SetFocus;
end;

procedure TInhEncomendaTeleMarketingForm.ProdutosDbGridEditButtonClick(
  Sender: TObject);
begin
   if (DataModule.ConsumoDSet.FieldByName('produto').AsInteger > 0) then
      DataModule.ProdutosDSet.Locate('id', VarArrayOf([DataModule.ConsumoDSet.FieldByName('produto').AsInteger]), []);

   if (InhLookupFromDataSource(DataModule.ProdutosDSource, 'descricao') = mrOk) then
      begin
          DataModule.ConsumoDSet.Edit;
          DataModule.ConsumoDSet.FieldByName('produto').Value := DataModule.ProdutosDSet.FieldByName('id').AsInteger;
      end;
   DataModule.ProdutosDSet.Filtered := False;
   with Sender as TDBGrid do
      SelectedIndex := SelectedIndex + 1;
end;

procedure TInhEncomendaTeleMarketingForm.ProdutosDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

procedure TInhEncomendaTeleMarketingForm.OkSpeedButtonClick(
  Sender: TObject);
begin
   if not (EncomendaAtiva and EncomendaCriada) then exit;

   with DataModule.PortaConsumoDSet do
      begin
         if State in [dsEdit] then
            begin
               Post;
               if ChangeCount > 0 then
                  ApplyUpdates(-1);
            end;
      end;

   with DataModule.EncomendaDSet do
      begin
         if State in [dsInsert,dsEdit] then
            begin
               Post;
               if ChangeCount > 0 then
                  ApplyUpdates(-1);
            end;
      end;

   with DataModule.ConsumoDSet do
      begin
         if (ChangeCount > 0) then
            begin
               // Se estiver em modo de insercao, e este registro estiver em branco,
               // delete-o.
               if (State in [dsInsert]) and
                  ((FieldByName('produto').AsInteger = 0) or (FieldByName('produto_quantidade').AsInteger = 0)) then
                  Delete;

               if (State in [dsEdit, dsBrowse]) then
                  begin
                     ApplyUpdates(0);
                  end;
            end;
      end;

   InhEncomendaTeleMarketingImpressaoDlgRun (Self,
                                             DataModule.PortaConsumoDSet.FieldByName('id').AsInteger);
   EncomendaAtiva := False;
   EncomendaCriada := False;
   PrepararParaNovaEncomenda();
end;

procedure TInhEncomendaTeleMarketingForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
   if (EncomendaAtiva)
      or
      (EncomendaCriada)
      or
      (DataModule.PortaConsumoDSet.FieldByName('id').AsInteger > 0) then
      if (InhDlgYesNo ('Deseja cancelar e deletar a encomenda atual?')) then
         begin
            InhEncomendaDelete (DataModule.PortaConsumoDSet.FieldByName('id').AsInteger);
            PrepararParaNovaEncomenda();
         end;
end;

procedure TInhEncomendaTeleMarketingForm.EnderecoButtonClick(
  Sender: TObject);
begin
   if (DataModule.EnderecoDSet.Active = true) then
      DataModule.EnderecoDSet.Close;

   DataModule.EnderecoDSet.Params[0].Value := DataModule.PortaConsumoDSet.FieldValues['dono'];
   DataModule.EnderecoDSet.Open;

   if DataModule.EnderecoDSet.RecordCount = 0 then
      InhDlg ('Desculpe, mas este cliente não possui endereços cadastrados.')
   else if (InhLookUpFromDataSource (DataModule.EnderecoDSource, 'endereco') = mrOK) then
      begin
        DataModule.EncomendaDSet.Edit;
        DataModule.EncomendaDSet.FieldValues['local_entrega'] := DataModule.EnderecoDSet.FieldValues['endereco'];
      end;
end;

end.
