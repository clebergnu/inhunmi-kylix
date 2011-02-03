unit InhReportViewer;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QPrinters, QExtCtrls, QStdCtrls, QButtons, InhBiblio, InhConfig, InhReport;

procedure InhReportViewerRun (FileName : String);
procedure InhReportViewerOrPrint (ReportFileName : String; ReportType : String);

type
  TInhReportViewerForm = class(TForm)
    ToolbarPanel: TPanel;
    ImpressoraLabel: TLabel;
    ImpressorasComboBox: TComboBox;
    Memo: TMemo;
    ImprimirSairSpeedButton: TSpeedButton;
    ImprimirSpeedButton: TSpeedButton;
    SalvarSpeedButton: TSpeedButton;
    SairSpeedButton: TSpeedButton;
    SaveDialog: TSaveDialog;
    procedure ImprimirSpeedButtonClick(Sender: TObject);
    procedure ImprimirSairSpeedButtonClick(Sender: TObject);
    procedure SairSpeedButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SalvarSpeedButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    FileName : String;
  end;

var
  InhReportViewerForm: TInhReportViewerForm;

implementation

{$R *.xfm}

procedure InhReportViewerRun (FileName : String);
var
   ViewerForm : TInhReportViewerForm;
   IndexOfDefaultPrinter : integer;
begin
   ViewerForm := TInhReportViewerForm.Create(Application);

   ViewerForm.FileName := FileName;
   ViewerForm.Memo.Lines.LoadFromFile(FileName);

   ViewerForm.ImpressorasComboBox.Items := Printer.Printers;
   IndexOfDefaultPrinter := ViewerForm.ImpressorasComboBox.Items.IndexOf(LocalConfig.ReadString('Impressao', 'ImpressoraPadrao', ''));
   if (IndexOfDefaultPrinter < 0) then
      IndexOfDefaultPrinter := 0;
   ViewerForm.ImpressorasComboBox.ItemIndex := IndexOfDefaultPrinter;

   ViewerForm.Show;
end;

procedure TInhReportViewerForm.ImprimirSpeedButtonClick(Sender: TObject);
begin
   InhReportRealPrint (Self.FileName, ImpressorasComboBox.Text);
end;

procedure TInhReportViewerForm.ImprimirSairSpeedButtonClick(
  Sender: TObject);
begin
   InhReportRealPrint (Self.FileName, ImpressorasComboBox.Text);
   Close;
end;

procedure TInhReportViewerForm.SairSpeedButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TInhReportViewerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   if FileName <> '' then
      DeleteFile(Self.FileName);
   FileName := '';
   Self.Release;
end;

procedure InhReportViewerOrPrint (ReportFileName : String; ReportType : String);
var
   Impressora : String;
begin
   Impressora := LocalConfig.ReadString('Relatorios', ReportType, '');
   if (Impressora = '') then
      InhReportViewerRun (ReportFileName)
   else if (Impressora = 'ImpressoraPadrao') then
      InhReportRealPrint (ReportFileName, '')
   else
      InhReportRealPrint (ReportFileName, Impressora);
end;

procedure TInhReportViewerForm.SalvarSpeedButtonClick(Sender: TObject);
begin
   if (SaveDialog.Execute) then
      Memo.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TInhReportViewerForm.FormCreate(Sender: TObject);
begin
   InhFormDealWithScreen (Self);
end;

end.
