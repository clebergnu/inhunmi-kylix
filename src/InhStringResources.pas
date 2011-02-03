unit InhStringResources;

interface

resourcestring

////////////////////////////////////////////////////////////////////////////
// InhStrRecord: Feedback to user editing records, mainly used in InhDbForm
////////////////////////////////////////////////////////////////////////////
InhStrRecordAdding = 'Novo registro sendo inserido, preencha os campos dispon�veis e confirme com (CTRL + Enter)';
InhStrRecordAdded = 'Registro "%s" adicionado. Preencha os outros campos dispon�veis. Confime com (CTRL + Enter)';
InhStrRecordModified = 'Registro %s foi modificado e ainda n�o teve suas altera��es salvas.';
InhStrRecordSaved = 'Registro %s teve as altera��es salvas';
InhStrRecordModifiedSaveConfirmation = 'O registro atual ainda n�o foi salvo. Deseja realmente sair e abandonar as altera��es?';

////////////////////////////////////////////////////////////////////////////
// InhStrTeleMarketing: Used in InhEncomendaTeleMarketing
////////////////////////////////////////////////////////////////////////////
InhStrTeleMarketingTelephoneNumber = 'Digite o n�mero de telefone do cliente';
InhStrTeleMarketingCustomersListed =  'Escolha um dos clientes listados';
InhStrTeleMarketingCustomerSelected = 'Cliente selecionado, encomenda criada';
InhStrTeleMarketingDeliveryDetailsSaved = 'Detalhes da entrega foram salvos';

////////////////////////////////////////////////////////////////////////////
// InhStrInput: User input data validation
////////////////////////////////////////////////////////////////////////////
InhStrInputInteger =  'Este campo requer um valor num�rico inteiro. (Exemplos: 1, 12, 23)';
InhStrInputFloat = 'Este campo requer um valor num�rico inteiro ou fracionado. (Exemplos: 1, 12.98, 76.12)';
   
////////////////////////////////////////////////////////////////////////////
// InhStrDlg: Default Messages on Misc Dialogs
////////////////////////////////////////////////////////////////////////////
InhStrDlgNotification = 'Aviso';
InhStrDlgNotImplemented = 'Desculpe, mas esta fun��o ainda n�o est� implementada.';

////////////////////////////////////////////////////////////////////////////
// InhStrDlgRecord: Messages on Dialogs Regarding Operations on Records
////////////////////////////////////////////////////////////////////////////
InhStrDlgRecordMasterDeleteConfirmation  = 'Tem certeza que deseja excluir este(a) %s e todas as informa��es relacionadas?';
InhStrDlgRecordDetailDeleteConfirmation = 'Tem certeza que deseja excluir este(a) %s?';
InhStrDlgRecordNotApplied = 'Desculpe mas n�o foi poss�vel executar esta opera��o. Verifique o estado do servidor e suas permiss�es de acesso ao mesmo.';

implementation

end.
