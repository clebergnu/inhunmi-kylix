unit InhDbDataModule;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, FMTBcd, DB, DBClient, DBLocal,
  DBLocalS, QControls, InhMainDM, InhBiblio;

type
  TInhDbDataModule = class(TDataModule)
     MasterDataSource : TDataSource;
     DetailsDataSourceList : TList;
  end;

implementation

end.
 