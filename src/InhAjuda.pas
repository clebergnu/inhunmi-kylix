unit InhAjuda;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QButtons, QComCtrls, InhBiblio, InhConfig;

procedure InhAjudaRun (Topico : String);

type
  TInhAjudaForm = class(TForm)
    TextBrowser: TTextBrowser;
    Bevel1: TBevel;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
     ArquivoDeAjuda : String;
     Topico : String;
  end;

var
  InhAjudaForm: TInhAjudaForm;

implementation

uses InhDlgUtils;

{$R *.xfm}

procedure InhAjudaRun (Topico : String);
begin
   if (InhAjudaForm = nil) then
      InhAjudaForm := TInhAjudaForm.Create(InhAjudaForm);
   InhAjudaForm.Topico := Topico;
   if (InhAjudaForm.ArquivoDeAjuda = '') then
      InhAjudaForm.ArquivoDeAjuda := GlobalConfig.ReadString('Ajuda', 'ArquivoDeAjuda', '');
   if (InhAjudaForm.ArquivoDeAjuda = '') then
      InhDlg ('Erro: Arquivo de ajuda não disponível!')
   else
      begin
         InhAjudaForm.TextBrowser.FileName := InhAjudaForm.ArquivoDeAjuda + '#' + Topico;
         InhAjudaForm.Show;
      end;
end;

procedure TInhAjudaForm.SpeedButton1Click(Sender: TObject);
begin
   Close;
end;

procedure TInhAjudaForm.FormCreate(Sender: TObject);
begin
   Left := 0;
   Top := 0;
end;

end.
