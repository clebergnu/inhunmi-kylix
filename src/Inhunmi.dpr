{Inhunmi.dpr - Inhunmi Project File

 Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA 02111-1307, USA.
}

program Inhunmi;



uses
  QForms,
  QStyle,
  QControls,
  SysUtils,
  IniFiles,
  DB,
  InhMainDM in 'InhMainDM.pas' {MainDM: TDataModule},
  InhPessoaDM in 'InhPessoaDM.pas' {PessoaDM: TDataModule},
  InhPessoa in 'InhPessoa.pas' {InhPessoaForm},
  InhBiblio in 'InhBiblio.pas',
  InhMain in 'InhMain.pas' {InhMainForm},
  InhFormaPagamento in 'InhFormaPagamento.pas' {InhFormaPagamentoForm},
  InhFormaPagamentoDM in 'InhFormaPagamentoDM.pas' {FormaPagamentoDM: TDataModule},
  InhProdutoDM in 'InhProdutoDM.pas' {ProdutoDM: TDataModule},
  InhProduto in 'InhProduto.pas' {InhProdutoForm},
  InhInstituicao in 'InhInstituicao.pas' {InhInstituicaoForm},
  InhInstituicaoDM in 'InhInstituicaoDM.pas' {InstituicaoDM: TDataModule},
  InhCaixaAtendimentoDM in 'InhCaixaAtendimentoDM.pas' {CaixaAtendimentoDM: TDataModule},
  InhCaixaAtendimento in 'InhCaixaAtendimento.pas' {InhCaixaAtendimentoForm},
  InhConsumoAdicionaDM in 'InhConsumoAdicionaDM.pas' {ConsumoAdicionaDM: TDataModule},
  InhConsumoAdiciona in 'InhConsumoAdiciona.pas' {InhConsumoAdicionaForm},
  InhFiltroPadrao in 'InhFiltroPadrao.pas' {InhFiltroPadraoForm},
  InhEncomendaDM in 'InhEncomendaDM.pas' {EncomendaDM: TDataModule},
  InhDepartamentoDM in 'InhDepartamentoDM.pas' {DepartamentoDM: TDataModule},
  InhDepartamento in 'InhDepartamento.pas' {InhDepartamentoForm},
  InhReport in 'InhReport.pas',
  InhAcessoDM in 'InhAcessoDM.pas' {AcessoDM: TDataModule},
  InhLogin in 'InhLogin.pas' {InhLoginForm},
  InhConfig in 'InhConfig.pas' {InhConfigForm},
  InhProdutoGrupo in 'InhProdutoGrupo.pas' {InhProdutoGrupoForm},
  InhProdutoGrupoDM in 'InhProdutoGrupoDM.pas' {ProdutoGrupoDM: TDataModule},
  InhConsumoCompostoDlg in 'InhConsumoCompostoDlg.pas' {InhConsumoCompostoDlgForm},
  InhLookupPadrao in 'InhLookupPadrao.pas' {InhLookupPadraoForm},
  InhCompromissoDM in 'InhCompromissoDM.pas' {CompromissoDM: TDataModule},
  InhCompromisso in 'InhCompromisso.pas' {InhCompromissoForm},
  InhOkCancelDlg in 'InhOkCancelDlg.pas' {InhOkCancelDlgForm},
  InhPessoaInstituicaoLookupDlg in 'InhPessoaInstituicaoLookupDlg.pas' {InhPessoaInstituicaoLookupDlgForm},
  InhPessoaInstituicaoDM in 'InhPessoaInstituicaoDM.pas' {PessoaInstituicaoDM: TDataModule},
  InhCaixaFechamento in 'InhCaixaFechamento.pas' {InhCaixaFechamentoForm},
  InhCaixaFechamentoDM in 'InhCaixaFechamentoDM.pas' {CaixaFechamentoDM: TDataModule},
  InhPortaConsumoNovo in 'InhPortaConsumoNovo.pas' {InhPortaConsumoNovoForm},
  InhReportCaixa in 'InhReportCaixa.pas',
  InhReportPortaConsumo in 'InhReportPortaConsumo.pas',
  InhReportStatusCaixaDlg in 'InhReportStatusCaixaDlg.pas' {InhReportStatusCaixaDlgForm},
  InhAjuda in 'InhAjuda.pas' {InhAjudaForm},
  InhLocale in 'InhLocale.pas',
  InhCaixaMovimentoDlg in 'InhCaixaMovimentoDlg.pas' {InhCaixaMovimentoDlgForm},
  InhCaixaTipoTrocoDlg in 'InhCaixaTipoTrocoDlg.pas' {InhCaixaTipoTrocoDlgForm},
  InhCaixa in 'InhCaixa.pas',
  InhReportViewer in 'InhReportViewer.pas' {InhReportViewerForm},
  InhReportVendas in 'InhReportVendas.pas',
  InhReportResumoVendasDlg in 'InhReportResumoVendasDlg.pas' {InhReportResumoVendasDlgForm},
  InhReportProduto in 'InhReportProduto.pas',
  InhReportProdutoTabelaPrecoVendido in 'InhReportProdutoTabelaPrecoVendido.pas' {InhReportProdutoTabelaPrecoVendidoDlgForm},
  InhReportPessoaInstituicao in 'InhReportPessoaInstituicao.pas',
  InhDbForm in 'InhDbForm.pas' {InhDbForm},
  InhDbDataModule in 'InhDbDataModule.pas',
  InhConsumoPropriedadesDlg in 'InhConsumoPropriedadesDlg.pas' {InhConsumoPropriedadesDlgForm},
  InhPortaConsumoPropriedadesDlg in 'InhPortaConsumoPropriedadesDlg.pas' {InhPortaConsumoPropriedadesDlgForm},
  InhPortaConsumoLookUpDlg in 'InhPortaConsumoLookUpDlg.pas' {InhPortaConsumoLookUpDlgForm},
  InhReportEncomenda in 'InhReportEncomenda.pas',
  InhEncomenda in 'InhEncomenda.pas' {InhEncomendaForm},
  InhDbFastLookUpDlg in 'InhDbFastLookUpDlg.pas' {InhDbFastLookUpDlgForm},
  InhLogger in 'InhLogger.pas',
  InhPortaConsumoFixo in 'InhPortaConsumoFixo.pas' {InhPortaConsumoFixoForm},
  InhPortaConsumoFixoDM in 'InhPortaConsumoFixoDM.pas' {PortaConsumoFixoDM: TDataModule},
  InhConsumoUtils in 'InhConsumoUtils.pas',
  InhPortaConsumoUtils in 'InhPortaConsumoUtils.pas',
  InhEncomendaTeleMarketing in 'InhEncomendaTeleMarketing.pas' {InhEncomendaTeleMarketingForm},
  InhEncomendaTeleMarketingDM in 'InhEncomendaTeleMarketingDM.pas' {EncomendaTeleMarketingDM: TDataModule},
  InhReportPendentes in 'InhReportPendentes.pas',
  InhDbGridUtils in 'InhDbGridUtils.pas',
  InhEncomendaUtils in 'InhEncomendaUtils.pas',
  InhGlobalDM in 'InhGlobalDM.pas' {GlobalDM: TDataModule},
  InhEncomendaTeleMarketingImpressaoDlg in 'InhEncomendaTeleMarketingImpressaoDlg.pas' {InhEncomendaTeleMarketingImpressaoDlgForm},
  InhProdutoDetalhes in 'InhProdutoDetalhes.pas' {InhProdutoDetalhesForm},
  InhPessoaUtils in 'InhPessoaUtils.pas',
  InhDlgUtils in 'InhDlgUtils.pas',
  InhDbDriverInfo in 'InhDbDriverInfo.pas',
  InhGerenciaFechamentoPortaConsumos in 'InhGerenciaFechamentoPortaConsumos.pas' {InhGerenciaFechamentoPortaConsumosForm},
  InhProdutoUtils in 'InhProdutoUtils.pas',
  InhInstituicaoUtils in 'InhInstituicaoUtils.pas',
  InhEncomendaTeleMarketingPessoaCadastro in 'InhEncomendaTeleMarketingPessoaCadastro.pas' {InhEncomendaTeleMarketingPessoaCadastroForm},
  InhReportEncomendaProducao in 'InhReportEncomendaProducao.pas',
  InhReportEncomendaProducaoResumoDlg in 'InhReportEncomendaProducaoResumoDlg.pas' {InhReportEncomendaProducaoResumoDlgForm},
  InhReportEncomendaListagem in 'InhReportEncomendaListagem.pas',
  InhReportEncomendaListagemHoraDlg in 'InhReportEncomendaListagemHoraDlg.pas' {InhReportEncomendaListagemHoraDlgForm},
  InhEncomendaLookUpDlg in 'InhEncomendaLookUpDlg.pas' {InhEncomendaLookUpDlgForm},
  InhStringResources in 'InhStringResources.pas',
  InhLogViewer in 'InhLogViewer.pas' {InhLogViewerForm},
  InhEstoqueUtils in 'InhEstoqueUtils.pas',
  InhEstoqueTeste in 'InhEstoqueTeste.pas' {InhEstoqueTesteForm},
  InhEstoqueMovimentoEntradaSimplesDlg in 'InhEstoqueMovimentoEntradaSimplesDlg.pas' {InhEstoqueMovimentoEntradaSimplesDlgForm},
  InhEstoqueTranferenciaSimplesDlg in 'InhEstoqueTranferenciaSimplesDlg.pas' {InhEstoqueTransferenciaSimplesDlgForm},
  InhReportEstoqueProdutoHistorico in 'InhReportEstoqueProdutoHistorico.pas',
  InhReportEstoqueComprovanteMovimento in 'InhReportEstoqueComprovanteMovimento.pas',
  InhReportEstoqueProduto in 'InhReportEstoqueProduto.pas',
  InhEstoqueMovimentoSaida in 'InhEstoqueMovimentoSaida.pas' {InhEstoqueMovimentoSaidaForm},
  InhEstoqueMovimentoSaidaDM in 'InhEstoqueMovimentoSaidaDM.pas' {EstoqueMovimentoSaidaDM: TDataModule},
  InhEstoqueMovimentoEntrada in 'InhEstoqueMovimentoEntrada.pas' {InhEstoqueMovimentoEntradaForm},
  InhEstoqueMovimentoEntradaDM in 'InhEstoqueMovimentoEntradaDM.pas' {EstoqueMovimentoEntradaDM: TDataModule},
  InhEstoqueMovimentoTransferenciaDM in 'InhEstoqueMovimentoTransferenciaDM.pas' {EstoqueMovimentoTransferenciaDM: TDataModule},
  InhEstoqueMovimentoTransferencia in 'InhEstoqueMovimentoTransferencia.pas' {InhEstoqueMovimentoTransferenciaForm},
  InhEstoqueAjusteSimplesDlg in 'InhEstoqueAjusteSimplesDlg.pas' {InhEstoqueAjusteSimplesDlgForm},
  InhEstoqueAjusteDM in 'InhEstoqueAjusteDM.pas' {EstoqueAjusteDM: TDataModule},
  InhEstoqueAjuste in 'InhEstoqueAjuste.pas',
  InhEstoqueMovimentoEntradaGrupo in 'InhEstoqueMovimentoEntradaGrupo.pas' {InhEstoqueMovimentoEntradaGrupoForm},
  InhEstoqueMovimentoEntradaGrupoDM in 'InhEstoqueMovimentoEntradaGrupoDM.pas' {EstoqueMovimentoEntradaGrupoDM: TDataModule},
  InhEstoqueMovimentoGrupoUtils in 'InhEstoqueMovimentoGrupoUtils.pas',
  InhEstoqueMovimentoSaidaGrupoDM in 'InhEstoqueMovimentoSaidaGrupoDM.pas' {EstoqueMovimentoSaidaGrupoDM: TDataModule},
  InhEstoqueMovimentoSaidaGrupo in 'InhEstoqueMovimentoSaidaGrupo.pas' {InhEstoqueMovimentoSaidaGrupoForm},
  InhEstoqueMovimentoTransferenciaGrupoDM in 'InhEstoqueMovimentoTransferenciaGrupoDM.pas' {EstoqueMovimentoTransferenciaGrupoDM: TDataModule},
  InhEstoqueMovimentoTransferenciaGrupo in 'InhEstoqueMovimentoTransferenciaGrupo.pas' {InhEstoqueMovimentoTransferenciaGrupoForm},
  InhEstoqueAjusteGrupoDM in 'InhEstoqueAjusteGrupoDM.pas' {EstoqueAjusteGrupoDM: TDataModule},
  InhEstoqueAjusteGrupo in 'InhEstoqueAjusteGrupo.pas' {InhEstoqueAjusteGrupoForm},
  InhEstoqueAjusteGrupoUtils in 'InhEstoqueAjusteGrupoUtils.pas',
  InhReportEstoqueMovimentoSimples in 'InhReportEstoqueMovimentoSimples.pas',
  InhReportEstoqueMovimentoGrupo in 'InhReportEstoqueMovimentoGrupo.pas',
  InhEstoqueMovimentoEntradaUtils in 'InhEstoqueMovimentoEntradaUtils.pas',
  InhEstoqueMovimentoSaidaSimplesDlg in 'InhEstoqueMovimentoSaidaSimplesDlg.pas' {InhEstoqueMovimentoSaidaSimplesDlgForm},
  InhReportEstoqueProdutoHistoricoData in 'InhReportEstoqueProdutoHistoricoData.pas',
  InhFiscalUtils in 'InhFiscalUtils.pas',
  InhFiscalReimprime in 'InhFiscalReimprime.pas';

{$R *.res}

begin
  InhLocaleInit();

  Application.Initialize;
  Application.Title := 'Inhunmi';
  Application.Style.DefaultStyle := dsWindows;
  Application.CreateForm(TMainDM, MainDM);
  Application.CreateForm(TInhMainForm, InhMainForm);
  InhMainForm.Top := 0;
  InhMainForm.Left := 0;

  InhConfigOpen();

  with MainDM.MainConnection do
     begin
        Connected := False;
        LibraryName := GlobalConfig.ReadString('ServidorDeDados', 'LibraryName', 'libmysqldbx.so.0.0');
        GetDriverFunc  := GlobalConfig.ReadString('ServidorDeDados', 'GetDriverFunc', 'getSQLDriverMYSQL');
        VendorLib := GlobalConfig.ReadString('ServidorDeDados', 'VendorLib', 'libmysqlclient.so.12.0.0');
        Params.Values['HostName'] := GlobalConfig.ReadString('ServidorDeDados', 'HostName', '127.0.0.1');
        Params.Values['Database'] := GlobalConfig.ReadString('ServidorDeDados', 'DataBase', 'inhunmi');
        AutoClone := True;
     end;

  if (MainDM.MainConnection.Connected = False) then
     begin
        Application.CreateForm(TInhLoginForm, InhLoginForm);
        InhLoginForm.UserNameEdit.Text := LocalConfig.ReadString('Acesso', 'Usuario', '');
        InhLoginForm.PasswordEdit.Text := LocalConfig.ReadString('Acesso', 'Senha', '');

        if (InhLoginForm.ShowModal = mrOK) then
           begin
              try
                 MainDM.MainConnection.Open;
              except
                 on EDataBaseError do
                    begin
                       InhDlg('Conexão ao servidor de banco de dados negada. ' +
                              'Cheque o seu servidor, seu nome e sua senha. '  +
                              format('Parametros Usados: ' +
                                     '(HostName=%s)' +
                                     '(Database=%s)' +
                                     '(LibraryName=%s) ' +
                                     '(GetDriverFunc=%s) ' +
                                     '(VendorLib=%s) ',
                                     [MainDM.MainConnection.Params.Values['HostName'],
                                      MainDM.MainConnection.Params.Values['Database'],
                                      MainDM.MainConnection.LibraryName,
                                      MainDM.MainConnection.GetDriverFunc,
                                      MainDM.MainConnection.VendorLib ]));
                       exit;
                    end;
              end;
              FreeAndNil(InhLoginForm);
           end
        else
           exit;
     end;

  InhUserName := InhMainConnectionGetUserName ();
  InhAccess := InhAccessGetFromUserName (InhUserName);

  InhMainForm.AbrirAtendimento.Enabled := InhAccess.atendimento;
  InhMainForm.AbrirCaixa.Enabled := InhAccess.caixa;
  InhMainForm.AbrirCaixaMovimentoDlg.Enabled := InhAccess.caixa;

  InhMainForm.GrupoCadastroMenu.Visible := InhAccess.grupo_cadastro;

  InhMainForm.AbrirPessoa.Enabled := InhAccess.cadastro_pessoa;
  InhMainForm.AbrirInstituicao.Enabled := InhAccess.cadastro_instituicao;
  InhMainForm.AbrirDepartamento.Enabled := InhAccess.cadastro_departamento;
  InhMainForm.AbrirProduto.Enabled := InhAccess.cadastro_produto;
  InhMainForm.AbrirProdutoGrupo.Enabled := InhAccess.cadastro_produto_grupo;
  InhMainForm.AbrirEncomenda.Enabled := InhAccess.cadastro_encomenda;
  InhMainForm.AbrirFormaPagamento.Enabled := InhAccess.cadastro_forma_pagamento;

  InhMainForm.GrupoRelatorioMenu.Visible := InhAccess.grupo_relatorio;
  InhMainForm.GrupoGerenciamentoMenu.Visible := InhAccess.grupo_gerenciamento;

  InhLogInit();
  Application.Run;
end.
