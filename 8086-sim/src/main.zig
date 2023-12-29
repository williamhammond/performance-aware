const std = @import("std");

const file_path = "";

const OpCode = enum(u8) {
    Mov = 0b100010,
};

const register_table = [2][8][]const u8{
    [8][]const u8{ "al", "cl", "dl", "bl", "ah", "ch", "dh", "bh" },
    [8][]const u8{ "ax", "cx", "dx", "bx", "sp", "bp", "si", "di" },
};

pub fn main() !void {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    std.debug.print("bits 16\n\n", .{});

    while (true) {
        const b1 = file.reader().readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const op_code: OpCode = @enumFromInt(b1 >> 2);
        switch (op_code) {
            OpCode.Mov => {
                const w_flag = b1 & 0x1;
                const d_flag = b1 & 0x2;

                const b2 = try file.reader().readByte();
                var op1 = register_table[w_flag][(b2 & 0b00111000) >> 3];
                var op2 = register_table[w_flag][(b2 & 0b00000111)];

                if (d_flag == 0) {
                    const tmp = op1;
                    op1 = op2;
                    op2 = tmp;
                }

                std.debug.print("mov {s}, {s}\n", .{ op1, op2 });
            },
        }
    }
}
