unit InhDbDriverInfo;

interface

uses SysUtils;

procedure InhDbDriverInfoDlgRun ();

implementation

uses InhDlgUtils, InhMainDM;

procedure InhDbDriverInfoDlgRun ();
var
   Info : string;
   Transacoes : string;
begin
   if (MainDM.MainConnection.TransactionsSupported) then
      Transacoes := 'Sim'
   else
      Transacoes := 'N�o';

   Info := '';
   Info := Info + Format('Nome Do Driver:  %s' + #10, [MainDM.MainConnection.DriverName]);
   Info := Info + Format('Nome Da Conex�o: %s' + #10, [MainDM.MainConnection.ConnectionName]);
   Info := Info + Format('Suporte a Transa��es: %s' + #10, [Transacoes]);
   Info := Info + Format('Comandos por Conex�o: %u' + #10, [MainDM.MainConnection.MaxStmtsPerConn]);

   InhDlg(Info);
end;

end.
