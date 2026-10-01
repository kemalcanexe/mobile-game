"""Tüki 2.0: ucunun üstünde süzülen, bacaksız, iskeletli tükenmez kalem karakter.

Blender'ın Python modülüyle (pip install bpy) çalışır; modeli, iskeleti ve
animasyonları kodla üretip glTF olarak yazar. Oyun bu dosyayı kullanır.

    python3 godot/tools/blender/tuki.py                 # assets/models/tuki/tuki.glb
    python3 godot/tools/blender/tuki.py --render out/   # ayrıca poz önizlemeleri

Eksenler (Blender): yukarı +Z, yüz -Y yönüne bakar. glTF'e geçince yüz +Z'ye
bakar; oyunda model 180° döndürülür.
"""
import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_GLB = os.path.join(HERE, "..", "..", "assets", "models", "tuki", "tuki.glb")
RENDER_DIR = sys.argv[sys.argv.index("--render") + 1] if "--render" in sys.argv else ""
FPS = 30

# ------------------------------------------------------------------ ölçüler (m)
TIP = 0.0          # uç bilyesinin altı
H0 = 0.56          # gövde tabanı (pirinç ucun üstü)
BODY_R = 0.34
BODY_H = 1.25
CAP_Z = H0 + 1.43
SHOULDER_Z = H0 + 0.74
FACE_Y = -0.33
EYE_Z = H0 + 0.94

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.fps = FPS


# ------------------------------------------------------------------ yardımcılar

def srgb(h):
    h = h.lstrip("#")
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)


def mat(name, hexcol, rough=0.35, metal=0.0, coat=0.0, emit=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    col = srgb(hexcol)
    b.inputs["Base Color"].default_value = (*col, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    b.inputs["Coat Weight"].default_value = coat
    if emit:
        b.inputs["Emission Color"].default_value = (*col, 1)
        b.inputs["Emission Strength"].default_value = emit
    return m


PARTS = []  # (obje, kemik adı)


def _finish(o, m, bone, bevel=0.0, sub=0, seg=3):
    o.data.materials.append(m)
    bpy.context.view_layer.objects.active = o
    if bevel:
        md = o.modifiers.new("bevel", "BEVEL")
        md.width = bevel
        md.segments = seg
        md.limit_method = "ANGLE"
    if sub:
        s = o.modifiers.new("sub", "SUBSURF")
        s.levels = sub
        s.render_levels = sub
    bpy.ops.object.shade_smooth()
    PARTS.append((o, bone))
    return o


def cyl(r, depth, z, m, bone, r2=None, verts=24, bevel=0.0, sub=0, loc=None):
    loc = loc or (0, 0, z)
    if r2 is None:
        bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=depth, location=loc, vertices=verts)
    else:
        bpy.ops.mesh.primitive_cone_add(radius1=r, radius2=r2, depth=depth, location=loc, vertices=verts)
    return _finish(bpy.context.object, m, bone, bevel, sub)


def sphere(r, loc, m, bone, scale=(1, 1, 1), seg=20):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=r, location=loc, segments=seg, ring_count=seg // 2)
    o = bpy.context.object
    o.scale = scale
    return _finish(o, m, bone)


def block(size, loc, m, bone, rot=(0, 0, 0), bevel=0.02):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=rot)
    o = bpy.context.object
    o.scale = size
    bpy.ops.object.transform_apply(scale=True)
    return _finish(o, m, bone, bevel=bevel, sub=1)


def limb(p0, p1, r0, r1, m, bone):
    p0, p1 = Vector(p0), Vector(p1)
    d = p1 - p0
    bpy.ops.mesh.primitive_cone_add(radius1=r0, radius2=r1, depth=d.length, location=(p0 + p1) / 2, vertices=16)
    o = bpy.context.object
    o.rotation_mode = "QUATERNION"
    o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d)
    _finish(o, m, bone)
    sphere(r0, p0, m, bone, seg=24)
    return o


# ------------------------------------------------------------------ malzemeler
WHITE = mat("tuki_body", "#F4F6FB", rough=0.25, coat=0.5)
INK = mat("tuki_ink", "#1F3A93", rough=0.3, coat=0.4)
INK_L = mat("tuki_ink_light", "#4F79E6", rough=0.35, coat=0.3)
CHROME = mat("tuki_chrome", "#DDE3EF", rough=0.2, metal=0.6)
BRASS = mat("tuki_brass", "#F0C06A", rough=0.3, metal=0.45)
EYE_W = mat("tuki_eye", "#FFFFFF", rough=0.1, coat=1.0)
IRIS = mat("tuki_iris", "#1B2A55", rough=0.1, coat=1.0)
SHINE = mat("tuki_shine", "#FFFFFF", rough=0.1, emit=2.0)
CHEEK = mat("tuki_cheek", "#FF8FA3", rough=0.6)
MOUTH = mat("tuki_mouth", "#2A1A2E", rough=0.5)
GLOVE = mat("tuki_glove", "#FFFFFF", rough=0.45)

# ------------------------------------------------------------------ gövde
cyl(BODY_R, BODY_H, H0 + BODY_H / 2, WHITE, "body", verts=32, bevel=0.12, sub=1)
cyl(BODY_R + 0.012, 0.36, H0 + 0.3, INK_L, "body", verts=32, bevel=0.05, sub=1)
for k in range(4):
    cyl(BODY_R + 0.022, 0.035, H0 + 0.15 + k * 0.1, INK, "body", verts=32, bevel=0.012, sub=1)
cyl(0.378, 0.05, H0 + 1.19, CHROME, "body", verts=32, bevel=0.015, sub=1)
# pirinç uç + mürekkep bilyesi (Tüki bunun üstünde süzülür)
cyl(0.3, 0.3, H0 - 0.15, BRASS, "body", r2=BODY_R, verts=32, bevel=0.03, sub=1)
cyl(0.05, 0.2, H0 - 0.4, BRASS, "body", r2=0.3, verts=24, bevel=0.02, sub=1)
sphere(0.055, (0, 0, TIP + 0.055), INK, "body")
# kapak, kubbe, klips (ayrı kemik: sallanır)
cyl(0.37, 0.52, CAP_Z, INK, "cap", verts=32, bevel=0.06, sub=1)
sphere(0.37, (0, 0, CAP_Z + 0.26), INK, "cap", scale=(1, 1, 0.62), seg=28)
block((0.08, 0.06, 0.62), (0, 0.4, CAP_Z - 0.07), CHROME, "cap", bevel=0.03)
sphere(0.075, (0, 0.43, CAP_Z - 0.37), CHROME, "cap")

# ------------------------------------------------------------------ yüz
for side, sx in (("L", -1), ("R", 1)):
    x = sx * 0.13
    sphere(0.12, (x, FACE_Y + 0.02, EYE_Z), EYE_W, "eye." + side, scale=(0.85, 0.55, 1.1))
    sphere(0.068, (x + sx * 0.005, FACE_Y - 0.045, EYE_Z - 0.01), IRIS, "eye." + side, scale=(0.9, 0.5, 1.05))
    sphere(0.024, (x - 0.02, FACE_Y - 0.085, EYE_Z + 0.035), SHINE, "eye." + side, seg=16)
    sphere(0.011, (x + 0.02, FACE_Y - 0.085, EYE_Z - 0.03), SHINE, "eye." + side, seg=12)
    sphere(0.06, (sx * 0.22, FACE_Y + 0.05, H0 + 0.78), CHEEK, "body", scale=(1, 0.4, 0.7), seg=16)
    block((0.09, 0.03, 0.022), (x, FACE_Y - 0.01, EYE_Z + 0.17), INK, "brow." + side, rot=(0, sx * -0.18, 0), bevel=0.008)
# gülümseme (alt yarım halka); ağız kemiğinin ölçeği -1 olunca somurtmaya döner
bpy.ops.mesh.primitive_torus_add(major_radius=0.07, minor_radius=0.014, location=(0, FACE_Y - 0.005, H0 + 0.8),
                                 rotation=(math.pi / 2, 0, 0), major_segments=24, minor_segments=6)
smile = bpy.context.object
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="DESELECT")
bpy.ops.object.mode_set(mode="OBJECT")
for v in smile.data.vertices:
    v.select = v.co.y > -0.005
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.delete(type="VERT")
bpy.ops.object.mode_set(mode="OBJECT")
_finish(smile, MOUTH, "mouth")

# ------------------------------------------------------------------ kollar (dinlenme: aşağı ve biraz yana)
ARM = {}
for side, sx in (("L", -1), ("R", 1)):
    sh = Vector((sx * 0.33, 0, SHOULDER_Z))
    el = sh + Vector((sx * 0.16, 0, -0.26))
    wr = el + Vector((sx * 0.04, -0.04, -0.24))
    ARM[side] = (sh, el, wr)
    limb(sh, el, 0.056, 0.05, INK, "arm_up." + side)
    limb(el, wr, 0.05, 0.047, INK, "arm_lo." + side)
    sphere(0.07, wr + Vector((0, 0, 0.03)), GLOVE, "hand." + side, scale=(1, 1, 0.6))
    sphere(0.1, wr + Vector((0, 0, -0.07)), GLOVE, "hand." + side, scale=(1, 0.9, 1))
    sphere(0.045, wr + Vector((sx * 0.07, -0.05, -0.03)), GLOVE, "hand." + side, seg=16)

# ------------------------------------------------------------------ iskelet
bpy.ops.object.armature_add(location=(0, 0, 0))
arm = bpy.context.object
arm.name = "TukiRig"
arm.data.name = "TukiRig"
bpy.ops.object.mode_set(mode="EDIT")
eb = arm.data.edit_bones
eb.remove(eb[0])


def bone(name, head, tail, parent=None):
    b = eb.new(name)
    b.head = head
    b.tail = tail
    b.roll = 0.0
    if parent:
        b.parent = eb[parent]
    return b


bone("root", (0, 0, 0), (0, 0.4, 0))
bone("body", (0, 0, TIP), (0, 0, H0 + 1.1), "root")          # uçtan döner: kalem ucunda eğilir
bone("cap", (0, 0, H0 + 1.17), (0, 0, CAP_Z + 0.5), "body")
for side, sx in (("L", -1), ("R", 1)):
    sh, el, wr = ARM[side]
    bone("arm_up." + side, sh, el, "body")
    bone("arm_lo." + side, el, wr, "arm_up." + side)
    bone("hand." + side, wr, wr + Vector((0, 0, -0.16)), "arm_lo." + side)
    x = sx * 0.13
    bone("eye." + side, (x, FACE_Y, EYE_Z), (x, FACE_Y, EYE_Z + 0.15), "body")
    bone("brow." + side, (x, FACE_Y, EYE_Z + 0.17), (x, FACE_Y, EYE_Z + 0.27), "body")
bone("mouth", (0, FACE_Y, H0 + 0.8), (0, FACE_Y, H0 + 0.9), "body")
bpy.ops.object.mode_set(mode="OBJECT")

# parçaları kemiklere bağla (dünya konumu korunur)
bpy.context.view_layer.update()
for o, bname in PARTS:
    mw = o.matrix_world.copy()
    o.parent = arm
    o.parent_type = "BONE"
    o.parent_bone = bname
    bpy.context.view_layer.update()
    o.matrix_world = mw

# ------------------------------------------------------------------ animasyonlar
arm.animation_data_create()
for pb in arm.pose.bones:
    pb.rotation_mode = "QUATERNION" if pb.name in ("arm_up.L", "arm_up.R", "arm_lo.L", "arm_lo.R", "hand.L", "hand.R") else "XYZ"

D = math.radians


WORLD_BONES = ("arm_up.L", "arm_up.R", "arm_lo.L", "arm_lo.R", "hand.L", "hand.R")


def reset_pose():
    for pb in arm.pose.bones:
        pb.location = (0, 0, 0)
        pb.rotation_euler = (0, 0, 0)
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.scale = (1, 1, 1)


def world_rot(pb, deg):
    """Karakter eksenlerinde (X sağ, Y arka, Z yukarı) verilen dönüşü kemiğin yerel dönüşüne çevirir."""
    from mathutils import Euler
    r = Euler(tuple(D(a) for a in deg), "XYZ").to_matrix()
    m = pb.bone.matrix_local.to_3x3()
    return (m.inverted() @ r @ m).to_quaternion()


def key(frame, pose):
    """pose: {kemik: {"r": yerel derece, "w": karakter ekseninde derece, "l": konum, "s": ölçek}}."""
    reset_pose()
    for bname, v in pose.items():
        pb = arm.pose.bones[bname]
        if "w" in v:
            pb.rotation_quaternion = world_rot(pb, v["w"])
        if "r" in v:
            pb.rotation_euler = tuple(D(a) for a in v["r"])
        if "l" in v:
            pb.location = v["l"]
        if "s" in v:
            pb.scale = v["s"]
    for pb in arm.pose.bones:
        pb.keyframe_insert("rotation_quaternion" if pb.rotation_mode == "QUATERNION" else "rotation_euler", frame=frame)
        pb.keyframe_insert("location", frame=frame)
        pb.keyframe_insert("scale", frame=frame)


ACTIONS = []


def action(name, frames, loop=True):
    act = bpy.data.actions.new(name)
    act.use_fake_user = True
    arm.animation_data.action = act
    for f, pose in frames:
        key(f, pose)
    # döngülerde son kare ilk kareyle aynı olsun
    ACTIONS.append((name, act, loop, frames[-1][0]))
    return act


# Gövde kemiğinde X etrafında + dönüş öne (yüz tarafına, -Y) eğer.
# Kollar karakter ekseninde verilir: swing + = el öne gider, raise + = kol yana/yukarı kalkar,
# bend - = dirsek öne kırılır. (Aşağı sarkan kol: X etrafında - dönüş öne, Y etrafında sol + / sağ - yukarı.)
def arms(l_swing=0.0, r_swing=0.0, l_out=0.0, r_out=0.0, l_bend=0.0, r_bend=0.0):
    return {
        "arm_up.L": {"w": (-l_swing, l_out, 0)}, "arm_up.R": {"w": (-r_swing, -r_out, 0)},
        "arm_lo.L": {"w": (l_bend, 0, 0)}, "arm_lo.R": {"w": (r_bend, 0, 0)},
    }


def merge(*ds):
    out = {}
    for d in ds:
        for k, v in d.items():
            out.setdefault(k, {}).update(v)
    return out


# bekleme: hafif süzülme ve göz kırpma
action("idle", [
    (1, merge({"root": {"l": (0, 0, 0.0)}}, arms(0, 0, 8, 8, -10, -10))),
    (20, merge({"root": {"l": (0, 0, 0.04)}, "cap": {"r": (2, 0, 0)}}, arms(4, -4, 12, 12, -16, -16))),
    (38, merge({"root": {"l": (0, 0, 0.0)}, "eye.L": {"s": (1, 1, 0.1)}, "eye.R": {"s": (1, 1, 0.1)}}, arms(0, 0, 8, 8, -10, -10))),
    (41, merge({"root": {"l": (0, 0, 0.0)}}, arms(0, 0, 8, 8, -10, -10))),
    (60, merge({"root": {"l": (0, 0, 0.0)}}, arms(0, 0, 8, 8, -10, -10))),
])

# süzülme (koşu): uçta öne eğik, paten kayar gibi kollar, sağa-sola salınım
G = 14
action("glide", [
    (1, merge({"body": {"r": (G, 0, 4)}, "cap": {"r": (-6, 0, -3)}}, arms(-45, 40, 18, 22, -30, -50))),
    (6, merge({"body": {"r": (G + 2, 0, 0)}, "root": {"l": (0, 0, 0.03)}, "cap": {"r": (-4, 0, 0)}}, arms(0, 0, 20, 20, -40, -40))),
    (11, merge({"body": {"r": (G, 0, -4)}, "cap": {"r": (-6, 0, 3)}}, arms(40, -45, 22, 18, -50, -30))),
    (16, merge({"body": {"r": (G + 2, 0, 0)}, "root": {"l": (0, 0, 0.03)}, "cap": {"r": (-4, 0, 0)}}, arms(0, 0, 20, 20, -40, -40))),
    (21, merge({"body": {"r": (G, 0, 4)}, "cap": {"r": (-6, 0, -3)}}, arms(-45, 40, 18, 22, -30, -50))),
])

# havada: kollar yukarıda çırpar, gözler açık
action("air", [
    (1, merge({"body": {"r": (-6, 0, 0)}, "cap": {"r": (8, 0, 0)}, "eye.L": {"s": (1.1, 1, 1.15)},
               "eye.R": {"s": (1.1, 1, 1.15)}, "mouth": {"s": (0.7, 1, 1.4)}}, arms(-20, -20, 110, 110, -20, -20))),
    (8, merge({"body": {"r": (-8, 0, 0)}, "cap": {"r": (4, 0, 0)}, "eye.L": {"s": (1.1, 1, 1.15)},
               "eye.R": {"s": (1.1, 1, 1.15)}, "mouth": {"s": (0.7, 1, 1.4)}}, arms(-20, -20, 135, 135, -10, -10))),
    (15, merge({"body": {"r": (-6, 0, 0)}, "cap": {"r": (8, 0, 0)}, "eye.L": {"s": (1.1, 1, 1.15)},
                "eye.R": {"s": (1.1, 1, 1.15)}, "mouth": {"s": (0.7, 1, 1.4)}}, arms(-20, -20, 110, 110, -20, -20))),
])

# kayma: kalem öne yatar, kollar süpermen gibi ileride
action("slide", [
    (1, merge({"body": {"r": (72, 0, 0)}, "cap": {"r": (-8, 0, 0)}, "root": {"l": (0, 0, 0.12)}}, arms(-150, -150, 10, 10, 0, 0))),
    (8, merge({"body": {"r": (74, 0, 3)}, "cap": {"r": (-12, 0, 0)}, "root": {"l": (0, 0, 0.12)}}, arms(-155, -145, 14, 6, 0, 0))),
    (15, merge({"body": {"r": (72, 0, 0)}, "cap": {"r": (-8, 0, 0)}, "root": {"l": (0, 0, 0.12)}}, arms(-150, -150, 10, 10, 0, 0))),
])

# sendeleme: geriye savrulur, kollar çırpınır, gözler kapanır
action("stumble", [
    (1, merge({"body": {"r": (-16, 0, 10)}, "eye.L": {"s": (1, 1, 0.1)}, "eye.R": {"s": (1, 1, 0.1)},
               "brow.L": {"r": (0, 0, -20)}, "brow.R": {"r": (0, 0, 20)}, "mouth": {"s": (1, 1, -1)}},
              arms(-60, 30, 70, 90, -30, -60))),
    (5, merge({"body": {"r": (8, 0, -12)}, "cap": {"r": (-10, 0, 8)}, "eye.L": {"s": (1, 1, 0.1)},
               "eye.R": {"s": (1, 1, 0.1)}, "mouth": {"s": (1, 1, -1)}}, arms(40, -50, 100, 60, -60, -20))),
    (9, merge({"body": {"r": (-6, 0, 6)}, "mouth": {"s": (1, 1, -1)}}, arms(-10, 10, 40, 40, -30, -30))),
    (12, merge({"body": {"r": (G, 0, 0)}}, arms(0, 0, 20, 20, -40, -40))),
], loop=False)

# zafer: kollar havada, zıplama, kapak sallanır
action("victory", [
    (1, merge({"root": {"l": (0, 0, 0)}, "body": {"s": (1.06, 1.06, 0.92)}, "mouth": {"s": (1.4, 1, 1.4)}},
              arms(15, 15, 125, 125, -20, -20))),
    (8, merge({"root": {"l": (0, 0, 0.35)}, "body": {"r": (0, 0, 8)}, "cap": {"r": (0, 0, -12)},
               "mouth": {"s": (1.4, 1, 1.4)}}, arms(15, 15, 140, 115, -10, -30))),
    (15, merge({"root": {"l": (0, 0, 0)}, "body": {"s": (1.06, 1.06, 0.92)}, "mouth": {"s": (1.4, 1, 1.4)}},
               arms(15, 15, 125, 125, -20, -20))),
    (22, merge({"root": {"l": (0, 0, 0.35)}, "body": {"r": (0, 0, -8)}, "cap": {"r": (0, 0, 12)},
                "mouth": {"s": (1.4, 1, 1.4)}}, arms(15, 15, 115, 140, -30, -10))),
    (29, merge({"root": {"l": (0, 0, 0)}, "body": {"s": (1.06, 1.06, 0.92)}, "mouth": {"s": (1.4, 1, 1.4)}},
               arms(15, 15, 125, 125, -20, -20))),
])

# üzgün: öne düşer, kollar sarkık, kaşlar ve ağız aşağı
SAD = {"brow.L": {"r": (0, 0, 22)}, "brow.R": {"r": (0, 0, -22)}, "mouth": {"s": (1, 1, -1)},
       "eye.L": {"s": (1, 1, 0.75)}, "eye.R": {"s": (1, 1, 0.75)}}
action("sad", [
    (1, merge({"body": {"r": (18, 0, 0)}, "cap": {"r": (10, 0, 0)}}, SAD, arms(10, 10, 2, 2, 0, 0))),
    (30, merge({"body": {"r": (22, 0, 2)}, "cap": {"r": (14, 0, 0)}, "root": {"l": (0, 0, -0.03)}}, SAD, arms(14, 14, 0, 0, 0, 0))),
    (60, merge({"body": {"r": (18, 0, 0)}, "cap": {"r": (10, 0, 0)}}, SAD, arms(10, 10, 2, 2, 0, 0))),
])

# el sallama (menü)
action("wave", [
    (1, merge({"body": {"r": (0, 0, -4)}}, arms(0, -10, 8, 150, -10, -40), {"hand.R": {"w": (0, 20, 0)}})),
    (8, merge({"body": {"r": (0, 0, -5)}, "root": {"l": (0, 0, 0.03)}}, arms(0, -10, 8, 150, -10, -70), {"hand.R": {"w": (0, -20, 0)}})),
    (15, merge({"body": {"r": (0, 0, -4)}}, arms(0, -10, 8, 150, -10, -40), {"hand.R": {"w": (0, 20, 0)}})),
    (22, merge({"body": {"r": (0, 0, -5)}, "root": {"l": (0, 0, 0.03)}}, arms(0, -10, 8, 150, -10, -70), {"hand.R": {"w": (0, -20, 0)}})),
    (29, merge({"body": {"r": (0, 0, -4)}}, arms(0, -10, 8, 150, -10, -40), {"hand.R": {"w": (0, 20, 0)}})),
])

arm.animation_data.action = bpy.data.actions["idle"]
reset_pose()

# ------------------------------------------------------------------ dışa aktarım
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_apply=True, export_animations=True,
                          export_animation_mode="ACTIONS", export_force_sampling=True,
                          export_frame_range=False, export_yup=True)
print("glb ->", os.path.abspath(OUT_GLB))


# ------------------------------------------------------------------ önizleme renderları
def render_poses(out_dir):
    os.makedirs(out_dir, exist_ok=True)
    bpy.ops.mesh.primitive_plane_add(size=30, location=(0, 0, 0))
    floor = bpy.context.object
    floor.data.materials.append(mat("floor", "#E8EEF9", rough=0.8))
    world = bpy.data.worlds.new("w")
    scene.world = world
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (*srgb("#DCE6F7"), 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6

    def light(loc, energy, color, size):
        bpy.ops.object.light_add(type="AREA", location=loc)
        l = bpy.context.object
        l.data.energy = energy
        l.data.color = color
        l.data.size = size
        l.rotation_euler = (Vector((0, 0, 1.1)) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()

    light((-2.5, -3.5, 4.0), 700, (1.0, 0.96, 0.9), 3.0)
    light((3.0, -2.0, 2.0), 220, (0.8, 0.88, 1.0), 2.5)
    light((1.5, 3.5, 3.5), 520, (0.75, 0.85, 1.0), 2.0)
    bpy.ops.object.camera_add(location=(2.6, -5.6, 2.0))
    cam = bpy.context.object
    cam.data.lens = 50
    cam.rotation_euler = (Vector((0, 0, 1.15)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 24
    scene.cycles.use_denoising = True
    scene.render.resolution_x = 600
    scene.render.resolution_y = 760
    scene.view_settings.view_transform = "AgX"
    for name, frame in [("idle", 20), ("glide", 1), ("air", 8), ("slide", 8), ("stumble", 5), ("victory", 8), ("sad", 30), ("wave", 8)]:
        arm.animation_data.action = bpy.data.actions[name]
        scene.frame_set(frame)
        scene.render.filepath = os.path.join(out_dir, f"pose_{name}.png")
        bpy.ops.render.render(write_still=True)
        print("render ->", name)


if RENDER_DIR:
    render_poses(RENDER_DIR)
