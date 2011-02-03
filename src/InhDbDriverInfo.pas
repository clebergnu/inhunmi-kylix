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
      Transacoes := 'Não';

   Info := '';
   Info := Info + Format('Nome Do Driver:  %s' + #10, [MainDM.MainConnection.DriverName]);
   Info := Info + Format('Nome Da Conexão: %s' + #10, [MainDM.MainConnection.ConnectionName]);
   Info := Info + Format('Suporte a Transações: %s' + #10, [Transacoes]);
   Info := Info + Format('Comandos por Conexão: %u' + #10, [MainDM.MainConnection.MaxStmtsPerConn]);

   InhDlg(Info);
end;

end.
