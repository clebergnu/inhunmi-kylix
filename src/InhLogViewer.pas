unit InhLogViewer;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QExtCtrls, QButtons;

type
  TInhLogViewerForm = class(TForm)
    ToolbarPanel: TPanel;
    PrintButton: TSpeedButton;
    LogoImage: TImage;
    FilterButton: TSpeedButton;
    ExitButton: TSpeedButton;
    HelpButton: TSpeedButton;
    ClearFilterButton: TSpeedButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhLogViewerForm: TInhLogViewerForm;

implementation

{$R *.xfm}

end.
