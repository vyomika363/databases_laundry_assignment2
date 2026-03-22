import time
import random
import tracemalloc
from .bplustree import BPlusTree
from .bruteforce import BruteForceDB


class PerformanceAnalyzer:
    def __init__(self, n=10000, runs=10):
        self.n = n
        self.runs = runs

    def generate_keys(self):
        return random.sample(range(1, 1000000), self.n)

    def test_insert(self):
        def run():
            keys = self.generate_keys()

            bpt = BPlusTree()
            bf = BruteForceDB()

            start = time.perf_counter()
            for k in keys:
                bpt.insert(k, k)
            bpt_time = time.perf_counter() - start

            start = time.perf_counter()
            for k in keys:
                bf.insert(k, k)
            bf_time = time.perf_counter() - start

            return bpt_time, bf_time

        results = [run() for _ in range(self.runs)]
        return (
            sum(x[0] for x in results) / self.runs,
            sum(x[1] for x in results) / self.runs,
        )

    def test_search(self):
        keys = self.generate_keys()

        bpt = BPlusTree()
        bf = BruteForceDB()

        for k in keys:
            bpt.insert(k, k)
            bf.insert(k, k)

        def run():
            search_keys = random.sample(keys, len(keys)) # shuffle

            start = time.perf_counter()
            for k in search_keys:
                bpt.search(k)
            bpt_time = time.perf_counter() - start

            start = time.perf_counter()
            for k in search_keys:
                bf.search(k)
            bf_time = time.perf_counter() - start

            return bpt_time, bf_time

        results = [run() for _ in range(self.runs)]
        return (
            sum(x[0] for x in results) / self.runs,
            sum(x[1] for x in results) / self.runs,
        )

    def test_range(self):
        keys = self.generate_keys()

        bpt = BPlusTree()
        bf = BruteForceDB()

        for k in keys:
            bpt.insert(k, k)
            bf.insert(k, k)

        sorted_keys = sorted(keys)

        def run():
            window = max(1, min(100, len(sorted_keys) // 10))

            start_idx = random.randint(0, len(sorted_keys) - window)
            start_key = sorted_keys[start_idx]
            end_key = sorted_keys[start_idx + window - 1]

            start = time.perf_counter()
            bpt.range_query(start_key, end_key)
            bpt_time = time.perf_counter() - start

            start = time.perf_counter()
            bf.range_query(start_key, end_key)
            bf_time = time.perf_counter() - start

            return bpt_time, bf_time

        results = [run() for _ in range(self.runs)]
        return (
            sum(x[0] for x in results) / self.runs,
            sum(x[1] for x in results) / self.runs,
        )

    def test_delete(self):
        keys = self.generate_keys()

        def run():
            bpt = BPlusTree()
            bf = BruteForceDB()

            for k in keys:
                bpt.insert(k, k)
                bf.insert(k, k)

            delete_keys = random.sample(keys, len(keys))  # shuffle

            start = time.perf_counter()
            for k in delete_keys:
                bpt.delete(k)
            bpt_time = time.perf_counter() - start

            start = time.perf_counter()
            for k in delete_keys:
                bf.delete(k)
            bf_time = time.perf_counter() - start

            return bpt_time, bf_time

        results = [run() for _ in range(self.runs)]
        return (
            sum(x[0] for x in results) / self.runs,
            sum(x[1] for x in results) / self.runs,
        )

    def memory_usage(self):
        keys = self.generate_keys()

        tracemalloc.start()
        bpt = BPlusTree()
        for k in keys:
            bpt.insert(k, k)
        bpt_mem = tracemalloc.get_traced_memory()[1]
        tracemalloc.stop()

        tracemalloc.start()
        bf = BruteForceDB()
        for k in keys:
            bf.insert(k, k)
        bf_mem = tracemalloc.get_traced_memory()[1]
        tracemalloc.stop()

        return bpt_mem, bf_mem