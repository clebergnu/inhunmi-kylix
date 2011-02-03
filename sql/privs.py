# -*- Mode: Python; coding: iso-8859-1 -*-
# vi:si:et:sw=4:sts=4:ts=4

##
## Inhunmi
## Copyright (C) 2006 Cleber Rodrigues <cleber@globalred.com.br>
## All rights reserved
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
## USA.
##
## Author(s): Cleber Rodrigues <cleber@globalred.com.br>
##

import getpass

from gloco.db.mysql_account import *

class InhAdminRole(DatabaseAdminRole):
    def __init__(self, username, password, host, db='inhunmi'):
        DatabaseAdminRole.__init__(self, username, password, host, db)
        self.extra_sql_lines.append('USE inhunmi')
        self.extra_sql_lines.append(\
            "INSERT INTO acesso VALUES (0, '%s', 'Sim', 'Sim', 'Sim', 'Sim'," \
            "'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', " \
            "'Sim', 'Sim'" % username)

class InhAtendRole(MySQLAccount):
    def __init__(self, username, password, host):
        MySQLAccount.__init__(self, username, password, host)

        self.add_privs(MySQLTablePriv('inhunmi', 'acesso', 'Select'),
                       MySQLTablePriv('inhunmi', 'porta_consumo', 'Select'),
                       MySQLTablePriv('inhunmi', 'produto', 'Select'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao', 'Select'),
                       MySQLTablePriv('inhunmi', 'consumo', 'Select', 'Insert'),
                       MySQLTablePriv('inhunmi', 'porta_consumo_pagamento', \
                                      'Select'),
                       MySQLTablePriv('inhunmi', 'encomenda', 'Select'))

        self.extra_sql_lines.append('USE inhunmi')
        self.extra_sql_lines.append(\
            "INSERT INTO acesso (id, usuario, atendimento) " \
            "VALUES (0, '%s', 'Sim')" % username)

class InhCaixaRole(MySQLAccount):
    def __init__(self, username, password, host):
        MySQLAccount.__init__(self, username, password, host)

        self.add_privs(MySQLTablePriv('inhunmi', 'acesso', 'Select'),
                       MySQLTablePriv('inhunmi', 'porta_consumo', \
                                      'Select', 'Insert', 'Update'),
                       MySQLTablePriv('inhunmi', 'produto', 'Select'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao', 'Select'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao_pessoa', \
                                      'Select'),
                       MySQLTablePriv('inhunmi', 'consumo', 'Select', 'Insert'),
                       MySQLTablePriv('inhunmi', 'porta_consumo_pagamento', \
                                      'Select', 'Insert'),
                       MySQLTablePriv('inhunmi', 'caixa_movimento', 'Insert'),
                       MySQLTablePriv('inhunmi', 'forma_pagamento', 'Select'),
                       MySQLTablePriv('inhunmi', 'encomenda', 'Select'))

        self.extra_sql_lines.append('USE inhunmi')
        self.extra_sql_lines.append(\
            "INSERT INTO acesso (id, usuario, atendimento, caixa) " \
            "VALUES (0, '%s', 'Sim', 'Sim')" % username)

class InhTelemarketingRole(MySQLAccount):
    def __init__(self, username, password, host):
        MySQLAccount.__init__(self, username, password, host)

        self.add_privs(MySQLTablePriv('inhunmi', 'acesso', 'Select'),
                       MySQLTablePriv('inhunmi', 'porta_consumo', \
                                      'Select', 'Insert', 'Update', 'Delete'),
                       MySQLTablePriv('inhunmi', 'porta_consumo_pagamento', \
                                      'Select', 'Delete'),
                       MySQLTablePriv('inhunmi', 'produto', 'Select'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao', \
                                      'Select', 'Insert', 'Update', 'Delete'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao_pessoa', \
                                      'Select', 'Insert', 'Update', 'Delete'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao_telefone', \
                                      'Select', 'Insert', 'Update', 'Delete'),
                       MySQLTablePriv('inhunmi', 'pessoa_instituicao_endereco', \
                                      'Select', 'Insert', 'Update', 'Delete'),
                       MySQLTablePriv('inhunmi', 'consumo', 'Select', \
                                      'Insert', 'Delete'),
                       MySQLTablePriv('inhunmi', 'forma_pagamento', 'Select'),
                       MySQLTablePriv('inhunmi', 'encomenda', \
                                      'Select', 'Insert', 'Update', 'Delete'),
                       MySQLTablePriv('inhunmi', 'departamento', 'Select'))

        self.extra_sql_lines.append('USE inhunmi')
        self.extra_sql_lines.append(\
            "INSERT INTO acesso (id, usuario, atendimento, cadastro_pessoa, " \
            "cadastro_encomenda) VALUES (0, '%s', 'Sim', 'Sim', 'Sim')" \
            % username)

if __name__ == '__main__':
    ChosenRole = InhAdminRole
    #ChosenRole = InhAtendRole
    #ChosenRole = InhCaixaRole
    #ChosenRole = InhTelemarketingRole



    username = raw_input('Username: ')
    password = getpass.getpass('Password: ')
    host = '%'

    inh_role = ChosenRole(username, password, host)
    print inh_role.build_new_user_sql()
