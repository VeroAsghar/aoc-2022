const std = @import("std");
const fs = std.fs;
const ArrayList = std.ArrayList;

const FileTree = struct {
    const File = struct { name: []const u8, size: usize, parent: *Node };
    const Dir = struct { name: []const u8, parent: ?*Node, children: ?[]Node };

    const Node = union(enum) {
        D: Dir,
        F: File,

        fn changeDir(alloc: std.mem.Allocator, n: **Node, p: *Parser, root: *Node) !*Node {
            _ = alloc;
            const tok = try p.nextToken();

            if (tok == .name) {
                const name = tok.name;
                _ = try p.nextToken();

                if (std.mem.eql(u8, "/", name)) {
                    return root;
                } else if (std.mem.eql(u8, "..", name)) {
                    return n.*.D.parent.?;
                } else {
                    if (n.*.D.children) |children| {
                        for (children) |*child| {
                            if (child.* == .D) {
                                if (std.mem.eql(u8, child.D.name, name)) {
                                    return child;
                                }
                            } else {
                                continue;
                            }
                        }
                    } else {
                        unreachable;
                    }
                }
            } else {
                unreachable;
            }
            unreachable;
        }

        fn setChildren(n: *Node, p: *Parser) !void {
            var list = ArrayList(Node).init(std.heap.page_allocator);
            defer list.deinit();

            _ = try p.nextToken(); // new line
            while (p.peekTok != .dollar and p.peekTok != .eof) {
                const tok = try p.nextToken();

                const name_tok = try p.nextToken();
                const child_node = switch (tok) {
                    .number => |num| blk: {
                        const size = try std.fmt.parseInt(usize, num, 10);
                        const name = name_tok.name;
                        const file = File{ .name = name, .size = size, .parent = n };
                        break :blk Node{ .F = file };
                    },
                    .dir => blk: {
                        const name = name_tok.name;
                        const dir = Dir{ .name = name, .parent = n, .children = null };
                        break :blk Node{ .D = dir };
                    },
                    else => unreachable,
                };

                try list.append(child_node);

                _ = try p.nextToken(); // new line

            }
            n.*.D.children = try list.toOwnedSlice();
        }
    };

    head: *Node,
    alloc: std.mem.Allocator,

    const Self = @This();

    fn parseNode(ft: *Self, p: *Parser) !void {
        var current = ft.head;
        while (p.peekTok != .eof) {
            const tok = try p.nextToken();
            if (tok == .dollar) {
                switch (try p.nextToken()) {
                    .cd => current = try Node.changeDir(ft.alloc, &current, p, ft.head),
                    .ls => try Node.setChildren(current, p),
                    else => unreachable,
                }
            } else {
                return error.DidNotWrapToCommand;
            }
        }
    }

    pub fn createTree(alloc: std.mem.Allocator, p: *Parser) !Self {
        var root = Node{ .D = .{ .name = "/", .parent = null, .children = undefined } };

        var head = try alloc.create(Node);
        head.* = root;

        var ft = Self{ .head = head, .alloc = alloc };
        try ft.parseNode(p);

        return ft;
    }

    pub fn printTree(n: *Node, depth: usize) void {
        var buf: [32]u8 = undefined;
        @memset(&buf, ' ');
        switch (n.*) {
            .F => |payload| {
                _ = std.fmt.bufPrint(buf[depth * 2 ..], "- {s} (file, size={d})", .{ payload.name, payload.size }) catch unreachable;
                std.debug.print("{s}\n", .{buf});
            },
            .D => |payload| {
                _ = std.fmt.bufPrint(buf[depth * 2 ..], "- {s} (dir)", .{payload.name}) catch unreachable;
                std.debug.print("{s}\n", .{buf});
                for (payload.children.?) |*child| {
                    printTree(child, depth + 1);
                }
            },
        }
    }

    pub fn calculateSizes(n: *Node, list: *ArrayList(usize)) usize {
        switch (n.*) {
            .F => |payload| return payload.size,
            .D => |payload| {
                var total: usize = 0;
                for (payload.children.?) |*child| {
                    total += calculateSizes(child, list);
                }
                list.append(total) catch unreachable;
                return total;
            },
        }
    }

    pub fn totalSum1(n: *Node, list: *ArrayList(usize)) usize {
        switch (n.*) {
            .F => |payload| return payload.size,
            .D => |payload| {
                var total: usize = 0;
                for (payload.children.?) |*child| {
                    total += totalSum1(child, list);
                }
                if (total <= 100_000) {
                    list.append(total) catch unreachable;
                }
                return total;
            },
        }
    }
};

const Parser = struct {
    curTok: Lexer.Token = undefined,
    peekTok: Lexer.Token = undefined,
    lexer: Lexer,

    pub fn init(input: []const u8) !Parser {
        const lexer = Lexer.init(input);

        var p = Parser{
            .lexer = lexer,
        };

        p.peekTok = try p.lexer.readToken();

        return p;
    }

    pub fn nextToken(p: *Parser) !Lexer.Token {
        p.curTok = p.peekTok;
        p.peekTok = try p.lexer.readToken();
        return p.curTok;
    }

    const Lexer = struct {
        const Token = union(enum) {
            dollar,
            cd,
            ls,
            dir,
            name: []const u8,
            number: []const u8,
            eof,
            nl,
        };

        input: []const u8,
        position: usize = 0,
        read_position: usize = 0,
        ch: u8 = undefined,

        const Self = @This();

        pub fn init(input: []const u8) Self {
            var l = Self{
                .input = input,
            };
            l.readChar();
            return l;
        }

        fn isLetter(ch: u8) bool {
            return 'a' <= ch and ch <= 'z' or 'A' <= ch and ch <= 'Z' or ch == '_';
        }
        fn isDigit(ch: u8) bool {
            return '0' <= ch and ch <= '9';
        }

        fn readNumber(l: *Self) []const u8 {
            const position = l.position;
            while (isDigit(l.ch)) {
                l.readChar();
            }
            return l.input[position..l.position];
        }

        fn readName(l: *Self) []const u8 {
            const position = l.position;
            while (isLetter(l.ch) or l.ch == '.') {
                l.readChar();
            }
            return l.input[position..l.position];
        }

        fn readChar(l: *Self) void {
            if (l.read_position >= l.input.len) {
                l.ch = 0;
            } else {
                l.ch = l.input[l.read_position];
            }
            l.position = l.read_position;
            l.read_position += 1;
        }

        fn consumeWhitespace(l: *Self) void {
            while (l.ch == ' ' or l.ch == '\t') {
                l.readChar();
            }
        }

        pub fn readToken(l: *Self) !Token {
            l.consumeWhitespace();
            const tok: Token = switch (l.ch) {
                0 => .eof,
                '$' => .dollar,
                '\n' => .nl,
                '/' => .{ .name = "/" },
                'a'...'z', 'A'...'Z', '.' => {
                    const name = l.readName();
                    return lookupName(name);
                },
                '0'...'9' => {
                    const num = l.readNumber();
                    return .{ .number = num };
                },
                else => return error.UnexpectedToken,
            };
            l.readChar();
            return tok;
        }

        pub fn lookupName(str: []const u8) Token {
            if (std.mem.eql(u8, "cd", str)) {
                return .cd;
            } else if (std.mem.eql(u8, "ls", str)) {
                return .ls;
            } else if (std.mem.eql(u8, "dir", str)) {
                return .dir;
            } else {
                return .{ .name = str };
            }
        }
    };
};

pub fn main() !void {
    std.debug.print("   \n", .{});
    const input_file = try fs.cwd().openFile("input.in", .{});
    defer input_file.close();

    const input = try fs.File.readToEndAlloc(input_file, std.heap.page_allocator, try std.math.powi(usize, 2, 16));
    defer std.heap.page_allocator.free(input);

    var p = try Parser.init(input);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const ft = try FileTree.createTree(allocator, &p);
    //FileTree.printTree(ft.head, 0);
    var list = ArrayList(usize).init(std.heap.page_allocator);
    _ = FileTree.calculateSizes(ft.head, &list);
    const total = 70_000_000;
    const needed = 30_000_000;
    const unused = total - list.getLast();

    for (list.items) |item| {
        if (item + unused > needed) {
            std.debug.print("{d}\n", .{item});
        }
    }
}

test "test" {
    std.debug.print("   \n", .{});
    const input_file = try fs.cwd().openFile("test.in", .{});
    defer input_file.close();

    const input = try fs.File.readToEndAlloc(input_file, std.testing.allocator, 2048);
    defer std.testing.allocator.free(input);

    var p = try Parser.init(input);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const ft = try FileTree.createTree(allocator, &p);
    FileTree.printTree(ft.head, 0);
    var list = ArrayList(usize).init(std.heap.page_allocator);
    _ = FileTree.calculateSizes(ft.head, &list);
    const total = 70_000_000;
    const needed = 30_000_000;
    const unused = total - list.getLast();

    for (list.items) |item| {
        if (item + unused > needed) {
            std.debug.print("{d}\n", .{item});
            break;
        }
    }
}
