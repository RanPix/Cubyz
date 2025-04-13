const std = @import("std");

const vec = @import("vec.zig");

const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec3i = vec.Vec3i;

pub const Animation = struct {
	const Frame = struct {
		duration: f64,
		position: Vec3d,
		rotation: Vec3d,
	};

	loop: bool = true,
	time: f64 = 0,
	currentFrame: u32 = 0,

	frames: [4]Frame = .{
		.{
			.duration = 0.3,
			.position = .{0, 0, 0},
			.rotation = .{0, 0, 0},
		},
		.{
			.duration = 0.3,
			.position = .{0.2, -0.1, 0.35},
			.rotation = .{0, std.math.pi*0.5, 0}, // TODO: turn degrees to radians automatically
		},
		.{
			.duration = 0.4,
			.position = .{-0.2, 0.8, -0.05},
			.rotation = .{-std.math.pi*0.1, -std.math.pi*0.1, 0},
		},
		.{
			.duration = 0,
			.position = .{0, 0, 0},
			.rotation = .{0, 0, 0},
		},
	},

	pub fn update(self: *Animation, deltaTime: f64) void {
		self.time += deltaTime;

		if(self.frames[self.currentFrame].duration <= self.time) {
			self.currentFrame += 1;
			self.time = 0;
		}

		if(self.loop and self.currentFrame >= self.frames.len-1) {
			self.currentFrame = 0;
		}
	}

	pub fn getPosition(self: *Animation) Vec3d {
		const current = self.currentFrame;
		return std.math.lerp(
			self.frames[current].position, 
			self.frames[current+1].position, 
			@as(Vec3d, @splat(easeInOut(self.time/self.frames[current].duration))),
			);
	}

	pub fn getRotation(self: *Animation) Vec3d {
		const current = self.currentFrame;
		return std.math.lerp(
			self.frames[current].rotation, 
			self.frames[current+1].rotation, 
			@as(Vec3d, @splat(easeInOut(self.time/self.frames[current].duration))),
			);
	}

	pub inline fn easeInOut(x: f64) f64 {
		return -(@cos(std.math.pi*x) - 1)*0.5;
	}

	pub inline fn easeIn(x: f64) f64 {
		return 1 - @cos(std.math.pi*x*0.5);
	}
};