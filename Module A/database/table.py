from .bplustree import BPlusTree

class Table:
    def __init__(self, name):
        self.name = name
        self.index = BPlusTree()

    def insert(self, key, value):
        self.index.insert(key, value)

    def search(self, key):
        return self.index.search(key)

    def delete(self, key):
        return self.index.delete(key)

    def update(self, key, value):
        return self.index.update(key, value)

    def range_query(self, start, end):
        return self.index.range_query(start, end)

    def get_all(self):
        return self.index.get_all()