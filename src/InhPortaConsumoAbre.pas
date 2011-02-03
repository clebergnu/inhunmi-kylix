unit InhPortaConsumoAbre;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QMask;

type
  TInhPortaConsumoAbreForm = class(TForm)
    TipoPortaConsumoComboBox: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    MaskEdit1: TMaskEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhPortaConsumoAbreForm: TInhPortaConsumoAbreForm;

implementation

{$R *.xfm}

end.
