unit InhTeste;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QDBCtrls, QGrids, QDBGrids, InhConsumoAdicionaDM;

type
  TInhTesteForm = class(TForm)
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhTesteForm: TInhTesteForm;

implementation

{$R *.xfm}

end.
