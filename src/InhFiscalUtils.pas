unit InhFiscalUtils;

interface

uses  SysUtils, Types, Classes, Variants,
      InhBiblio, InhConfig, InhDlgUtils
{$IFDEF LINUX}
,Libc
{$ENDIF LINUX}
;

type

CouponArray = array of integer;

procedure InhFiscalQueueCoupon(Coupons : CouponArray);
procedure InhFiscalSummarize();
procedure InhFiscalSummarizeAndClose();
procedure InhFiscalCancelLastCoupon();

const
   InhFiscalSuccess = 'Comando executado com sucesso.';
   InhFiscalError = 'Impossível executar comando. Verifique a existência do programa "inh-fiscal-client".';

implementation

function RunPosixCommand(command : string) : boolean;
var
   system_return : integer;
   exit_status   : integer;
begin
   result := False;

   {$IFDEF LINUX}
   system_return := Libc.system (PChar(command));
   exit_status := Libc.WEXITSTATUS(system_return);

   if exit_status = 0 then
      result := True;
   {$ENDIF LINUX}
end;

// Solicita impressao de cupom fiscal
procedure InhFiscalQueueCoupon(Coupons : CouponArray);
begin
   {$IFDEF LINUX}
   if (RunPosixCommand('inh-fiscal-client --queue-coupon=' +
                       InhArrayOfIntToStrList(Coupons, ',')) = True) then
      InhDlg(InhFiscalSuccess)
   else
      InhDlg(InhFiscalError);
   {$ENDIF LINUX}
end;

procedure InhFiscalSummarize();
begin
   if InhDlgYesNo('Esta operação inicializa a impressora e deve ser executada no inicio' +
                  'do dia. Confirma operação (Leitura X)?') then
      if
      {$IFDEF LINUX}
      RunPosixCommand('inh-fiscal-client --summarize')
      {$ENDIF LINUX}
      then
         InhDlg(InhFiscalSuccess)
      else
         InhDlg(InhFiscalError);
end;

procedure InhFiscalSummarizeAndClose();
begin
   if InhDlgYesNo('Esta operação fecha a impressora, impossibilitando ' +
                  'vendas e outras operações até o fim do dia. Confirma ' +
                  'operação (Redução Z)?') then
      if
      {$IFDEF LINUX}
      RunPosixCommand('inh-fiscal-client --summarize-and-close')
      {$ENDIF LINUX}
      then
         InhDlg(InhFiscalSuccess)
      else
         InhDlg(InhFiscalError);
end;

procedure InhFiscalCancelLastCoupon();
begin
   if InhDlgYesNo('Esta operação cancela o último coupon fiscal enviado ' +
                  'para a impressora. Confirma a operação ?') then
      if
      {$IFDEF LINUX}
      RunPosixCommand('inh-fiscal-client --cancel-last-coupon')
      {$ENDIF LINUX}
      then
         InhDlg(InhFiscalSuccess)
      else
         InhDlg(InhFiscalError);
end;

end.
