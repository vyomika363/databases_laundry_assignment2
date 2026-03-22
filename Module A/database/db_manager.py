from .table import Table

class DBManager:
    def __init__(self):
        self.tables = {}

    def create_table(self, name):
        self.tables[name] = Table(name)

    def get_table(self, name):
        return self.tables.get(name)

    def insert(self, table, key, value):
        self.tables[table].insert(key, value)

    def search(self, table, key):
        return self.tables[table].search(key)

    def delete(self, table, key):
        return self.tables[table].delete(key)

    def update(self, table, key, value):
        return self.tables[table].update(key, value)

    def range_query(self, table, start, end):
        return self.tables[table].range_query(start, end)

    def get_all(self, table):
        return self.tables[table].get_all()