import MySQLdb

from pprint import pprint

db_host  = '192.168.1.11'

def admin_connection(*args, **kwargs):
    kwargs.update({'user' : 'root',
                   'db' : 'mysql'})
    return MySQLdb.connect(*args, **kwargs)

class DBPrivileges:
    def __init__(self, host='localhost', database='test', username=''):
	self.host = host
	self.database = database
	self.username = username

    def fetch_privileges_from_db(self, username=None):
        if username == None:
            username = self.username
        c = admin_connection(host=db_host)
	cr = c.cursor()
        cr.execute('SELECT * FROM user WHERE User="%s"' % username)
        d = cr.fetchall()
        pprint(d)

class Admin(DBPrivileges):
    def __init__(self, host='localhost', database='test', username=''):
	DBPrivileges.__init__(self, host, database, username)

def test():
   a = Admin()
   a.fetch_privileges_from_db()

test()

admin_role_template_sql=["""INSERT INTO user VALUES ('%(host)s','%(username)s', PASSWORD('%(password)s'),'N','N','N','N','N','N','N','N','N','N','N','N','N','N')""",
                         """INSERT INTO db VALUES ('%(host)s','%(database)s','%(username)s','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y')"""]

def create_role(role_sql, **kwargs):
    c = admin_connection(host=db_host)
    
