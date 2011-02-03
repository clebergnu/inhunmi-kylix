unit InhReportSmallViewer;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, InhReport, QButtons, QExtCtrls;

procedure InhReportSmallViewerRun (FileName : String);

type
  TInhReportSmallViewerForm = class(TForm)
    Memo: TMemo;
    ToolbarPanel: TPanel;
    PrintButton: TSpeedButton;
    ExitButton: TSpeedButton;
    HelpButton: TSpeedButton;
    procedure PrintButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    FileName : String;
    { Public declarations }
  end;

var
  InhReportSmallViewerForm: TInhReportSmallViewerForm;

implementation

{$R *.xfm}

procedure InhReportSmallViewerRun (FileName : String);
begin
   if (InhReportSmallViewerForm = nil) then
      InhReportSmallViewerForm := TInhReportSmallViewerForm.Create(Application);

   InhReportSmallViewerForm.FileName := FileName;
   InhReportSmallViewerForm.Memo.Lines.LoadFromFile(FileName);
   InhReportSmallViewerForm.ShowModal;
end;

procedure TInhReportSmallViewerForm.PrintButtonClick(Sender: TObject);
begin
   InhReportRealPrint (Self.FileName);
end;

procedure TInhReportSmallViewerForm.ExitButtonClick(Sender: TObject);
begin
   DeleteFile(Self.FileName);
   Close;
end;

end.
