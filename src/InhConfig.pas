unit InhConfig;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QButtons, QStdCtrls, QComCtrls, IniFiles, QDBCtrls, QMask, InhAcessoDM
{$IFDEF LINUX}
,Libc
{$ENDIF LINUX}
;

procedure InhConfigFormOpen ();
procedure InhConfigOpen ();
procedure InhConfigRead ();
procedure InhConfigWrite ();

type
  TInhConfigForm = class(TForm)
    ToolbarPanel: TPanel;
    SalvarButton: TSpeedButton;
    SairButton: TSpeedButton;
    ImpressaoSpeedButton: TSpeedButton;
    GeralSpeedButton: TSpeedButton;
    AcessoSpeedButton: TSpeedButton;
    PageControl: TPageControl;
    ImpressaoTabSheet: TTabSheet;
    MetodoGroupBox: TGroupBox;
    Label2: TLabel;
    GeralTabSheet: TTabSheet;
    AcessoTabSheet: TTabSheet;
    RelatorioGroupBox: TGroupBox;
    PrimeiraLinhaEdit: TEdit;
    PrimeiraLinhaLabel: TLabel;
    SegundaLinhaLabel: TLabel;
    SegundaLinhaEdit: TEdit;
    TerceiraLinhaEdit: TEdit;
    TerceiraLinhaLabel: TLabel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    DiasAnterioresSpinEdit: TSpinEdit;
    DiasFuturosSpinEdit: TSpinEdit;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    Navigator: TDBNavigator;
    GroupBox2: TGroupBox;
    TabelaPessoaDbCheckBox: TDBCheckBox;
    CaixaAtendimentoDbCheckBox: TDBCheckBox;
    TabelaInstituicaoDbCheckBox: TDBCheckBox;
    TabelaDepartamentoDbCheckBox: TDBCheckBox;
    TabelaProdutoDbCheckBox: TDBCheckBox;
    TabelaFormaPagamentoDbCheckBox: TDBCheckBox;
    TabelaEncomendaDbCheckBox: TDBCheckBox;
    TabelaConsumoDbCheckBox: TDBCheckBox;
    AcessoDbCheckBox: TDBCheckBox;
    ConfiguracaoDbCheckBox: TDBCheckBox;
    TabelaProdutoGrupoDbCheckBox: TDBCheckBox;
    TabelaCompromissoDbCheckBox: TDBCheckBox;
    Label4: TLabel;
    AtualizarIntervaloSpinEdit: TSpinEdit;
    procedure ImpressaoSpeedButtonClick(Sender: TObject);
    procedure GeralSpeedButtonClick(Sender: TObject);
    procedure AcessoSpeedButtonClick(Sender: TObject);
    procedure SairButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AcessoTabSheetShow(Sender: TObject);
    procedure AcessoTabSheetHide(Sender: TObject);
    procedure SalvarButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
   GlobalConfigFile : String = 'inhunmi.conf';
{$IFDEF LINUX}
   // Check current dir, then /etc, then /usr/local
   GlobalConfigPaths : array[0..2] of string = ('', '/etc/', '/usr/local/etc/');
{$ENDIF}
{$IFDEF WINDOWS}
   // Check current dir, then inhunmi install dir, then root of the current drive
   GlobalConfigPaths : array[0..1] of string = ('.\', '\inhunmi\', '\');
{$ENDIF}

var
   InhConfigForm    : TInhConfigForm;
   GlobalConfig     : TMemIniFile;
   LocalConfig	    : TMemIniFile;
   LocalConfigFile  : String;


implementation

{$R *.xfm}

procedure InhConfigOpen ();
var
   EnvDir : PChar;
   HomeDir : PChar;
   PathCount : integer;

   CurrentConfigFile : string;
begin
{$IFDEF LINUX}
   EnvDir := getenv('INHUNMI_CONFIG_FILE');

   if (EnvDir = '') then
      for PathCount := Low(GlobalConfigPaths) to High(GlobalConfigPaths) do
         begin
            CurrentConfigFile := GlobalConfigPaths[PathCount] + GlobalConfigFile;
            if (FileExists(CurrentConfigFile)) then
               begin
                  GlobalConfig := TMemIniFile.Create(CurrentConfigFile);
                  break;
               end;
         end
   else {EnvDir <> ''} 
      if (FileExists(String(EnvDir) + GlobalConfigFile)) then
         GlobalConfig := TMemIniFile.Create(String(EnvDir) + GlobalConfigFile);

   HomeDir := getenv ('HOME');
   LocalConfig  := TMemIniFile.Create(string (HomeDir) + '/.inhunmirc');
{$ENDIF}
end;

procedure InhConfigFormOpen ();
begin
   if InhConfigForm = nil then
      InhconfigForm := TInhConfigForm.Create(Application);

   InhConfigForm.Left := 0;
   InhConfigForm.Top := 0;
   InhConfigForm.Show;
end;

procedure InhConfigRead ();
begin
{
   InhConfigForm.PrimeiraLinhaEdit.Text := Config.ReadString('Impressao', 'CabecalhoLinha1', '');
   InhConfigForm.SegundaLinhaEdit.Text := Config.ReadString('Impressao', 'CabecalhoLinha2', '');
   InhConfigForm.TerceiraLinhaEdit.Text := Config.ReadString('Impressao', 'CabecalhoLinha3', '');
   InhConfigForm.DiasAnterioresSpinEdit.Value := Config.ReadInteger('Atendimento', 'DiasAnteriores', 1);
   InhConfigForm.DiasFuturosSpinEdit.Value := Config.ReadInteger('Atendimento', 'DiasFuturos', 1);
   InhConfigForm.AtualizarIntervaloSpinEdit.Value := Config.ReadInteger('Atendimento', 'IntervaloDeAtualizacao', 20);
}
end;

procedure InhConfigWrite ();
begin
{
   Config.WriteString('Impressao', 'CabecalhoLinha1', InhConfigForm.PrimeiraLinhaEdit.Text);
   Config.WriteString('Impressao', 'CabecalhoLinha2', InhConfigForm.SegundaLinhaEdit.Text);
   Config.WriteString('Impressao', 'CabecalhoLinha3', InhConfigForm.TerceiraLinhaEdit.Text);
   Config.WriteInteger('Atendimento', 'DiasAnteriores', InhConfigForm.DiasAnterioresSpinEdit.Value);
   Config.WriteInteger('Atendimento', 'DiasFuturos', InhConfigForm.DiasFuturosSpinEdit.Value);
   Config.WriteInteger('Atendimento', 'IntervaloDeAtualizacao', InhConfigForm.AtualizarIntervaloSpinEdit.Value);
   Config.UpdateFile;
}
end;


procedure TInhConfigForm.GeralSpeedButtonClick(Sender: TObject);
begin
   PageControl.ActivePage := GeralTabSheet;
end;

procedure TInhConfigForm.ImpressaoSpeedButtonClick(Sender: TObject);
begin
   PageControl.ActivePage := ImpressaoTabSheet;
end;

procedure TInhConfigForm.AcessoSpeedButtonClick(Sender: TObject);
begin
   PageControl.ActivePage := AcessoTabSheet;
end;

procedure TInhConfigForm.SairButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TInhConfigForm.FormActivate(Sender: TObject);
begin
   InhConfigRead ();
end;

procedure TInhConfigForm.AcessoTabSheetShow(Sender: TObject);
begin
   InhAcessoDMOpen();
end;

procedure TInhConfigForm.AcessoTabSheetHide(Sender: TObject);
begin
   InhAcessoDMClose();
end;

procedure TInhConfigForm.SalvarButtonClick(Sender: TObject);
begin
   InhConfigWrite ();
end;

end.
