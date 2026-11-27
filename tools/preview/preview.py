#!/usr/bin/env python3
"""Preview executions outside Roblox.

Renders rough frames of each execution (blocky R6 bodies, chainsaw, floor)
from the execution's own camera, and warns when the camera is inside or
very close to a body part. Needs Python 3 with numpy and Pillow, plus the
`luau` command line program (https://github.com/luau-lang/luau/releases).

    python tools/preview/preview.py                  # every move
    python tools/preview/preview.py BackSaw --fps 4  # one move
    python tools/preview/preview.py --check          # warnings only, no images

Images go to tools/preview/out/<Move>.png (a contact sheet per move).
"""

import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXEC_DIR = os.path.join(ROOT, "src", "shared", "Executions")
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")

# ---------------------------------------------------------------- data dump

JSON_LUAU = r"""
local function enc(v)
	local t = type(v)
	if t == "number" then
		if v ~= v then return "0" end
		return string.format("%.6g", v)
	elseif t == "string" then
		return '"' .. v:gsub('[%c"\\]', function(c) return string.format("\\u%04x", c:byte()) end) .. '"'
	elseif t == "boolean" then
		return tostring(v)
	elseif t == "table" then
		if #v > 0 or next(v) == nil then
			local out = {}
			for _, x in ipairs(v) do table.insert(out, enc(x)) end
			return "[" .. table.concat(out, ",") .. "]"
		end
		local out = {}
		for k, x in pairs(v) do
			if type(x) ~= "function" then
				table.insert(out, enc(tostring(k)) .. ":" .. enc(x))
			end
		end
		return "{" .. table.concat(out, ",") .. "}"
	end
	return "null"
end
"""


def registry_order():
    text = open(os.path.join(EXEC_DIR, "Registry.luau"), encoding="utf-8").read()
    block = re.search(r"Order\s*=\s*\{(.*?)\}", text, re.S).group(1)
    return re.findall(r'"(\w+)"', block)


def dump_moves(ids):
    luau = shutil.which("luau") or os.environ.get("LUAU")
    if not luau:
        sys.exit("Can't find the `luau` program. Put it on PATH or set LUAU=/path/to/luau")
    kit = open(os.path.join(EXEC_DIR, "Kit.luau"), encoding="utf-8").read()
    parts = [
        "local Color3 = { fromRGB = function(r, g, b) return { r, g, b } end, new = function(r, g, b) return { r * 255, g * 255, b * 255 } end }",
        "local warn = function(...) print('WARN', ...) end",
        JSON_LUAU,
        "local Kit = (function()\n" + kit + "\nend)()",
        "local result = {}",
    ]
    for move_id in ids:
        src = open(os.path.join(EXEC_DIR, "Moves", move_id + ".luau"), encoding="utf-8").read()
        parts.append(f'result["{move_id}"] = Kit.prepareMove("{move_id}", (function()\n{src}\nend)())')
    parts.append('print("JSON:" .. enc(result))')
    with tempfile.NamedTemporaryFile("w", suffix=".luau", delete=False, encoding="utf-8") as f:
        f.write("\n".join(parts))
        path = f.name
    try:
        proc = subprocess.run([luau, path], capture_output=True, text=True)
    finally:
        os.unlink(path)
    if proc.returncode != 0:
        sys.exit(proc.stdout + proc.stderr)
    for line in proc.stdout.splitlines():
        if line.startswith("WARN"):
            print(line)
        if line.startswith("JSON:"):
            return json.loads(line[5:])
    sys.exit("No output from luau:\n" + proc.stdout)


# ---------------------------------------------------------------- CFrame math


def cf(x=0, y=0, z=0, *r):
    m = np.eye(4)
    m[:3, 3] = (x, y, z)
    if r:
        m[:3, :3] = np.array(r, dtype=float).reshape(3, 3)
    return m


def rx(a):
    c, s = math.cos(a), math.sin(a)
    return cf(0, 0, 0, 1, 0, 0, 0, c, -s, 0, s, c)


def ry(a):
    c, s = math.cos(a), math.sin(a)
    return cf(0, 0, 0, c, 0, s, 0, 1, 0, -s, 0, c)


def rz(a):
    c, s = math.cos(a), math.sin(a)
    return cf(0, 0, 0, c, -s, 0, s, c, 0, 0, 0, 1)


def euler_yxz(x, y, z):
    return ry(y) @ rx(x) @ rz(z)


def rot_only(m):
    out = m.copy()
    out[:3, 3] = 0
    return out


def inv(m):
    return np.linalg.inv(m)


def root_cf(r):
    return cf(r[0], r[1], r[2]) @ euler_yxz(math.radians(r[3]), math.radians(r[4]), math.radians(r[5]))


def look_at(pos, target):
    pos, target = np.array(pos, float), np.array(target, float)
    fwd = target - pos
    fwd /= np.linalg.norm(fwd) or 1
    right = np.cross(fwd, [0, 1, 0])
    if np.linalg.norm(right) < 1e-6:
        right = np.array([1.0, 0, 0])
    right /= np.linalg.norm(right)
    up = np.cross(right, fwd)
    m = np.eye(4)
    m[:3, 0], m[:3, 1], m[:3, 2], m[:3, 3] = right, up, -fwd, pos
    return m


# Standard R6 joints: name -> (part0, part1, C0, C1)
R6 = {
    "Torso": ("HumanoidRootPart", "Torso", cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)),
    "Head": ("Torso", "Head", cf(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), cf(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)),
    "RArm": ("Torso", "Right Arm", cf(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), cf(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)),
    "LArm": ("Torso", "Left Arm", cf(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), cf(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)),
    "RLeg": ("Torso", "Right Leg", cf(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), cf(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)),
    "LLeg": ("Torso", "Left Leg", cf(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), cf(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)),
}
JOINT_ORDER = ["Torso", "Head", "RArm", "LArm", "RLeg", "LLeg"]


def solve_body(root, pose, detached=()):
    parts = {"HumanoidRootPart": root}
    for name in JOINT_ORDER:
        p0, p1, c0, c1 = R6[name]
        q = rot_only(c0)
        a = pose.get(name, [0, 0, 0])
        t = inv(q) @ euler_yxz(*(math.radians(v) for v in a)) @ q
        if name in detached:
            continue
        parts[p1] = parts[p0] @ c0 @ t @ inv(c1)
    return parts


# ---------------------------------------------------------------- models

SKIN = (180, 160, 140)
VICTIM = {
    "Head": ((1.2, 1.2, 1.2), (234, 184, 146)),
    "Torso": ((2, 2, 1), (40, 70, 120)),
    "Right Arm": ((1, 2, 1), (234, 184, 146)),
    "Left Arm": ((1, 2, 1), (234, 184, 146)),
    "Right Leg": ((1, 2, 1), (50, 45, 40)),
    "Left Leg": ((1, 2, 1), (50, 45, 40)),
}
KILLER = {
    "Head": ((1.35, 1.4, 1.35), (122, 98, 66)),
    "Torso": ((2.3, 2.1, 1.4), (40, 30, 24)),
    "Right Arm": ((1.05, 2, 1.05), (105, 100, 92)),
    "Left Arm": ((1.05, 2, 1.05), (105, 100, 92)),
    "Right Leg": ((1, 2, 1), (30, 28, 26)),
    "Left Leg": ((1, 2, 1), (30, 28, 26)),
}
# Must match KillerBuilder.addChainsaw
GRIP = cf(0, -1, 0) @ rx(math.radians(-90))
SAW = [
    (GRIP @ cf(0, 0.25, -0.35), (0.75, 0.95, 1.1), (120, 38, 22)),
    (GRIP @ cf(0, 0, -2.7), (0.12, 0.5, 3.6), (150, 150, 155)),
    (GRIP @ cf(0, 0, -4.55), (0.18, 0.66, 0.66), (35, 35, 38)),
]


def boxes_for(parts, spec, saw=False, tag=""):
    out = []
    for name, (size, color) in spec.items():
        if name in parts:
            m = parts[name]
            if name == "Head" and spec is KILLER:
                m = m @ cf(0, 0.1, 0)
            out.append((tag + name, m, size, color))
    if saw and "Right Arm" in parts:
        for off, size, color in SAW:
            out.append((tag + "Chainsaw", parts["Right Arm"] @ off, size, color))
    if spec is KILLER and "Head" in parts:
        for x in (-0.25, 0.25):
            out.append((tag + "Eye", parts["Head"] @ cf(x, 0.2, -0.72), (0.18, 0.18, 0.05), (255, 40, 30)))
    if spec is VICTIM and "Head" in parts:
        out.append((tag + "Face", parts["Head"] @ cf(0, 0, -0.61), (0.6, 0.15, 0.02), (40, 20, 20)))
    return out


# ---------------------------------------------------------------- sampling (mirrors Kit.luau)


def ease(name, t):
    if name == "linear":
        return t
    if name == "in":
        return t ** 3
    if name == "out":
        return 1 - (1 - t) ** 3
    if name == "back":
        c1 = 1.70158
        return 1 + (c1 + 1) * (t - 1) ** 3 + c1 * (t - 1) ** 2
    return 4 * t ** 3 if t < 0.5 else 1 - (-2 * t + 2) ** 3 / 2


def segment(track, t):
    if t <= track[0]["t"]:
        return track[0], track[0], 0
    if t >= track[-1]["t"]:
        return track[-1], track[-1], 0
    for a, b in zip(track, track[1:]):
        if t < b["t"]:
            span = b["t"] - a["t"]
            alpha = (t - a["t"]) / span if span > 0 else 1
            return a, b, ease(b.get("ease", "inOut"), alpha)
    return track[-1], track[-1], 0


def lerp(a, b, k):
    return [x + (y - x) * k for x, y in zip(a, b)]


def sample(track, t):
    a, b, k = segment(track, t)
    pose = {j: lerp(a["pose"][j], b["pose"][j], k) for j in JOINT_ORDER}
    return lerp(a["root"], b["root"], k), pose


def sample_cam(track, t):
    a, b, k = segment(track, t)
    return lerp(a["pos"], b["pos"], k), lerp(a["look"], b["look"], k), a["fov"] + (b["fov"] - a["fov"]) * k


def detached_at(move, who, t):
    out = set()
    for ev in move.get("ServerEvents", []):
        if ev.get("action") == "Detach" and ev.get("who", "Victim") == who and ev["t"] <= t:
            out.add(ev["joint"])
    return out


def scene(move, t):
    kroot, kpose = sample(move["Killer"], t)
    vt = min(t, move["KillTime"])
    vroot, vpose = sample(move["Victim"], vt)
    kparts = solve_body(root_cf(kroot), kpose)
    vparts = solve_body(root_cf(vroot), vpose, detached_at(move, "Victim", t))
    boxes = boxes_for(kparts, KILLER, saw=True, tag="K:") + boxes_for(vparts, VICTIM, tag="V:")
    return boxes, kparts, vparts


# ---------------------------------------------------------------- rendering

CUBE = np.array([[x, y, z] for x in (-0.5, 0.5) for y in (-0.5, 0.5) for z in (-0.5, 0.5)])
FACES = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
LIGHT = np.array([0.4, 0.8, 0.3])
LIGHT /= np.linalg.norm(LIGHT)


def box_corners(m, size):
    pts = CUBE * np.array(size)
    return (m[:3, :3] @ pts.T).T + m[:3, 3]


def inside(point, m, size, margin):
    local = inv(m) @ np.append(point, 1)
    return all(abs(local[i]) <= size[i] / 2 + margin for i in range(3))


def render(boxes, cam_cf, fov, w=480, h=270):
    img = Image.new("RGB", (w, h), (70, 90, 120))
    draw = ImageDraw.Draw(img)
    rinv = cam_cf[:3, :3].T
    cpos = cam_cf[:3, 3]
    tan = math.tan(math.radians(fov) / 2)

    def project(p):
        q = rinv @ (p - cpos)
        if q[2] > -0.05:
            return None, q[2]
        sx = q[0] / (-q[2] * tan * w / h)
        sy = q[1] / (-q[2] * tan)
        return ((sx + 1) * w / 2, (1 - sy) * h / 2), q[2]

    polys = []
    # floor tiles at y = -3
    for i in range(-12, 13, 2):
        for j in range(-16, 9, 2):
            corners = [np.array([i, -3, j]), np.array([i + 2, -3, j]), np.array([i + 2, -3, j + 2]), np.array([i, -3, j + 2])]
            proj = [project(c) for c in corners]
            if all(p[0] for p in proj):
                shade = (95, 95, 100) if (i + j) // 2 % 2 == 0 else (80, 80, 86)
                polys.append((min(p[1] for p in proj) - 1000, [p[0] for p in proj], shade))
    for _, m, size, color in boxes:
        pts = box_corners(m, size)
        for face in FACES:
            fp = pts[list(face)]
            normal = np.cross(fp[1] - fp[0], fp[2] - fp[0])
            n = np.linalg.norm(normal)
            if n == 0:
                continue
            normal /= n
            center = fp.mean(axis=0)
            if np.dot(normal, cpos - center) <= 0:
                continue
            proj = [project(p) for p in fp]
            if not all(p[0] for p in proj):
                continue
            light = 0.45 + 0.55 * max(0.0, float(np.dot(normal, LIGHT)))
            col = tuple(int(c * light) for c in color)
            depth = float(np.mean([p[1] for p in proj]))
            polys.append((depth, [p[0] for p in proj], col))
    polys.sort(key=lambda p: p[0])
    for _, pts, col in polys:
        draw.polygon(pts, fill=col, outline=(0, 0, 0))
    return img


def check_camera(move, times):
    problems = []
    for t in times:
        boxes, _, _ = scene(move, t)
        pos, look, _ = sample_cam(move["Camera"], t)
        p = np.array(pos)
        if np.linalg.norm(p - np.array(look)) < 4:
            problems.append(f"t={t:.2f}s camera is closer than 4 studs to what it looks at")
            continue
        for name, m, size, _ in boxes:
            if inside(p, m, size, 0.6):
                problems.append(f"t={t:.2f}s camera is inside/too close to {name}")
                break
    return problems


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("moves", nargs="*")
    parser.add_argument("--fps", type=float, default=3)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--side", action="store_true", help="also draw a fixed side view")
    args = parser.parse_args()

    ids = args.moves or registry_order()
    data = dump_moves(ids)
    os.makedirs(OUT_DIR, exist_ok=True)
    try:
        font = ImageFont.load_default(size=14)
    except TypeError:
        font = ImageFont.load_default()

    any_problem = False
    for move_id in ids:
        move = data[move_id]
        times = [round(i / args.fps, 3) for i in range(int(move["Duration"] * args.fps) + 1)]
        problems = check_camera(move, [i / 20 for i in range(int(move["Duration"] * 20) + 1)])
        for p in problems:
            print(f"{move_id}: {p}")
        any_problem |= bool(problems)
        if args.check:
            continue
        frames = []
        for t in times:
            boxes, _, _ = scene(move, t)
            pos, look, fov = sample_cam(move["Camera"], t)
            img = render(boxes, look_at(pos, look), fov)
            if args.side:
                side = render(boxes, look_at([12, 1, -3], [0, -0.5, -3]), 50)
                both = Image.new("RGB", (img.width * 2, img.height))
                both.paste(img, (0, 0))
                both.paste(side, (img.width, 0))
                img = both
            d = ImageDraw.Draw(img)
            tag = " KILL" if abs(t - move["KillTime"]) < 0.5 / args.fps else ""
            d.text((6, 4), f"{move_id} t={t:.2f}{tag}", fill=(255, 255, 0), font=font)
            frames.append(img)
        cols = 3 if args.side else 4
        rows = math.ceil(len(frames) / cols)
        fw, fh = frames[0].size
        sheet = Image.new("RGB", (fw * cols, fh * rows), (0, 0, 0))
        for i, f in enumerate(frames):
            sheet.paste(f, ((i % cols) * fw, (i // cols) * fh))
        path = os.path.join(OUT_DIR, f"{move_id}.png")
        sheet.save(path)
        print("wrote", path)
    if args.check and not any_problem:
        print("camera OK")


if __name__ == "__main__":
    main()
