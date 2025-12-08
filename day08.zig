const std = @import("std");

const Entry = struct {
    idx1: usize,
    idx2: usize,
    dist: u64,
};

const PQCtx = struct {};

fn pairLessThan(ctx: PQCtx, a: Entry, b: Entry) std.math.Order {
    _ = ctx;
    if (a.dist < b.dist) {return .lt;}
    else if (a.dist > b.dist) {return .gt;}
    else {return .eq;}
}

const Point3 = struct {
    x: i64,
    y: i64,
    z: i64,

    fn dist(self: Point3, other: Point3) u64 {
        const dx = @abs(self.x - other.x);
        const dy = @abs(self.y - other.y);
        const dz = @abs(self.z - other.z);
        return dx*dx + dy*dy + dz*dz;
    }
};

fn find(parents: []usize, i: usize) usize {
    if (parents[i] != i) {
        parents[i] = find(parents, parents[i]);
    }
    return parents[i];
}

fn union_(parents: []usize, sizes: []usize, i: usize, j: usize) void {
    const rootI = find(parents, i);
    const rootJ = find(parents, j);
    if (rootI != rootJ) {
        if (sizes[rootI] < sizes[rootJ]) {
            parents[rootI] = rootJ;
            sizes[rootJ] += sizes[rootI];
        } else {
            parents[rootJ] = rootI;
            sizes[rootI] += sizes[rootJ];
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var points = std.ArrayListUnmanaged(Point3){};
    defer points.deinit(alloc);

    // I need all this garbage just to read line-by-line?!
    // This feels worse than C.
    var buffer: [1024]u8 = undefined;
    var reader_wrapper = std.fs.File.stdin().reader(&buffer);
    const reader: *std.Io.Reader = &reader_wrapper.interface;
    
    while (reader.takeDelimiter('\n')) |line| {
        if (line == null) break;
        var parts = std.mem.splitScalar(u8, line.?, ',');
        const p = Point3{
            .x = std.fmt.parseInt(i64, parts.next().?, 10) catch continue,
            .y = std.fmt.parseInt(i64, parts.next().?, 10) catch continue,
            .z = std.fmt.parseInt(i64, parts.next().?, 10) catch continue,
        };
        try points.append(alloc, p);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    var pq = std.PriorityQueue(Entry, PQCtx, pairLessThan).init(alloc, PQCtx{});
    defer pq.deinit();

    for (points.items, 0..) |pi, i| {
        for (points.items[i + 1 ..], i + 1..) |pj, j| {
            const d = pi.dist(pj);
            try pq.add(Entry{
                .idx1 = i,
                .idx2 = j,
                .dist = d,
            });
        }
    }

    const n = points.items.len;
    var parents = try alloc.alloc(usize, n);
    defer alloc.free(parents);

    var sizes = try alloc.alloc(usize, n);
    defer alloc.free(sizes);

    for (0..n) |i| {
        parents[i] = i;
        sizes[i] = 1;
    }

    // Merge 1000 connections
    for (0..1000) |_| {
        const e = pq.remove();
        union_(parents, sizes, e.idx1, e.idx2);
    }

    // Creating a min heap is too much of a pain, so just track manually
    var a: usize = 0;
    var b: usize = 0;
    var c: usize = 0;
    for (0..n) |i| {
        if (parents[i] == i) {
            const size = sizes[i];
            if (size > a) {
                c = b;
                b = a;
                a = size;
            } else if (size > b) {
                c = b;
                b = size;
            } else if (size > c) {
                c = size;
            }
        }
    }
    std.log.info("Part 1: {d}", .{a*b*c});

    // Keep merging connections until only one component remains
    while (pq.items.len > 0) {
        const e = pq.remove();
        union_(parents, sizes, e.idx1, e.idx2);

        // Check if only one component remains
        var components: usize = 0;
        for (0..n) |i| {
            if (parents[i] == i) {
                components += 1;
                if (components > 1) break;
            }
        }
        if (components == 1) {
            const p1 = points.items[e.idx1];
            const p2 = points.items[e.idx2];
            std.log.info("Part 2: {d}", .{p1.x * p2.x});
            break;
        }
    }
}


