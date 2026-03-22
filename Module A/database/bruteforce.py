class BruteForceDB:
    def __init__(self):
        self.data = []

    def insert(self, key, value):
        self.data.append((key, value))

    def search(self, key):
        for k, v in self.data:
            if k == key:
                return v
        return None

    def delete(self, key):
        self.data = [(k, v) for k, v in self.data if k != key]

    def range_query(self, start, end):
        return [(k, v) for k, v in self.data if start <= k <= end]