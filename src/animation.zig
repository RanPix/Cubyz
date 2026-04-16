
const std = @import("std");

const vec = @import("vec.zig");
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec3i = vec.Vec3i;
const Vec4f = vec.Vec4f;

pub const Animation = struct {
	loop: bool = true,

	samplers: []Sampler,

	const Sampler = struct {
		T: type,
		affectedNode: u8,
		
		currentFrameTime: f64 = 0,
		currentFrame: u32 = 0,

		frames: []Frame = undefined,

		pub fn init(T: type, affectedNode: u8) Sampler {
			// std.builtin.Type
			if ((@typeInfo(T) != .Vector and @typeInfo(T).vector.child != .Float) or @typeInfo(T) != .Float) {
				return;
			}

			return .{
				.T = T,
				.affectedNode = affectedNode,
			};
		}
	};

	const Frame = struct {
		duration: f32,
		position: Vec3f,
		rotation: Vec4f,
		scale: Vec3f,
	};


	pub fn init() void {
		
	}

	pub fn update(self: *Animation, deltaTime: f64) void {
		self.currentFrameTime += deltaTime;

		if(self.frames[self.currentFrame].duration <= self.currentFrameTime) {
			self.currentFrame += 1;
			self.currentFrameTime = 0;
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
			self.currentFrameTime/self.frames[current].duration,
			// @as(Vec3d, @splat(easeInOut(self.currentFrameTime/self.frames[current].duration))),
			);
	}

	pub fn getRotation(self: *Animation) Vec3d {
		const current = self.currentFrame;
		return std.math.lerp(
			self.frames[current].rotation, 
			self.frames[current+1].rotation, 
			self.currentFrameTime/self.frames[current].duration,
			// @as(Vec3d, @splat(easeInOut(self.currentFrameTime/self.frames[current].duration))),
			);
	}

	pub inline fn easeInOut(x: f64) f64 {
		return -(@cos(std.math.pi*x) - 1)*0.5;
	}

	pub inline fn easeIn(x: f64) f64 {
		return 1 - @cos(std.math.pi*x*0.5);
	}
};