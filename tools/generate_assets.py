"""
Business Kids Asset Generator
"""
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

from PIL import Image, ImageDraw, ImageFont
import os

# ─── カラーパレット ───────────────────────────────────────────────
COLORS = {
    "orange":      "#FF6B35",
    "green":       "#4CAF50",
    "gold":        "#FFD700",
    "blue":        "#2196F3",
    "purple":      "#9C27B0",
    "pink":        "#E91E63",
    "teal":        "#009688",
    "red":         "#F44336",
    "brown":       "#795548",
    "light_green": "#8BC34A",
    "bg_light":    "#FFF8F0",
    "bg_green":    "#E8F5E9",
    "bg_blue":     "#E3F2FD",
    "white":       "#FFFFFF",
    "dark":        "#212121",
    "gray":        "#9E9E9E",
}

BASE = r"G:\マイドライブ\apps\business_kids\assets\images"

# ─── 描画ヘルパー ─────────────────────────────────────────────────

def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def make_canvas(size=(256, 256), bg="#FFFFFF"):
    img = Image.new("RGBA", size, (*hex_to_rgb(bg), 255))
    return img, ImageDraw.Draw(img)

def draw_rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    fill_rgb = (*hex_to_rgb(fill), 255)
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill_rgb)

def draw_circle(draw, center, radius, fill):
    cx, cy = center
    fill_rgb = (*hex_to_rgb(fill), 255)
    draw.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=fill_rgb)

def draw_emoji_text(draw, img, emoji, pos, size=120):
    """絵文字を中央に描く（フォールバック付き）"""
    try:
        # Segoe UI Emoji (Windows)
        font = ImageFont.truetype("seguiemj.ttf", size)
    except Exception:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/seguiemj.ttf", size)
        except Exception:
            font = ImageFont.load_default()

    # テキストサイズを取得して中央揃え
    bbox = draw.textbbox((0, 0), emoji, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = pos[0] - tw // 2
    y = pos[1] - th // 2
    draw.text((x, y), emoji, font=font, embedded_color=True)

def draw_label(draw, text, pos, color="#212121", size=24):
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/meiryo.ttc", size)
    except Exception:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/msgothic.ttc", size)
        except Exception:
            font = ImageFont.load_default()
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    x = pos[0] - tw // 2
    draw.text((x, pos[1]), text, font=font, fill=(*hex_to_rgb(color), 255))

def save(img, folder, filename):
    path = os.path.join(BASE, folder, filename)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, "PNG")
    print(f"  ✅ {folder}/{filename}")

# ─── お店アセット ─────────────────────────────────────────────────

def make_store(name, bg_top, bg_bot, roof_color, sign_color, emoji_list, label, size=(512, 512)):
    img, draw = make_canvas(size, bg_bot)
    w, h = size

    # グラデーション背景（簡易）
    top_rgb = hex_to_rgb(bg_top)
    bot_rgb = hex_to_rgb(bg_bot)
    for y in range(h):
        t = y / h
        r = int(top_rgb[0] * (1 - t) + bot_rgb[0] * t)
        g = int(top_rgb[1] * (1 - t) + bot_rgb[1] * t)
        b = int(top_rgb[2] * (1 - t) + bot_rgb[2] * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))

    # 屋根
    roof_pts = [(w*0.05, h*0.38), (w*0.5, h*0.15), (w*0.95, h*0.38)]
    draw.polygon(roof_pts, fill=(*hex_to_rgb(roof_color), 255))

    # 建物本体
    draw_rounded_rect(draw, [w*0.1, h*0.35, w*0.9, h*0.88], 12, COLORS["white"])

    # 看板
    draw_rounded_rect(draw, [w*0.15, h*0.37, w*0.85, h*0.52], 8, sign_color)
    draw_label(draw, label, (w//2, int(h*0.42)), color=COLORS["white"], size=32)

    # ドア
    draw_rounded_rect(draw, [w*0.38, h*0.65, w*0.62, h*0.88], 8, COLORS["bg_blue"])
    draw_circle(draw, (int(w*0.6), int(h*0.77)), 6, COLORS["gray"])

    # 商品絵文字
    for i, em in enumerate(emoji_list):
        x = int(w * (0.25 + i * 0.25))
        draw_emoji_text(draw, img, em, (x, int(h * 0.62)), size=52)

    # 地面
    draw.rectangle([0, int(h*0.88), w, h], fill=(*hex_to_rgb(COLORS["gray"]), 80))

    return img

def gen_stores():
    print("\n[STORE] Generating store assets...")

    img = make_store(
        "small_store", COLORS["bg_light"], "#FFE0B2",
        COLORS["orange"], COLORS["orange"],
        ["🍋"], "レモネードスタンド"
    )
    save(img, "store", "small_store.png")

    img = make_store(
        "medium_store", COLORS["bg_green"], "#C8E6C9",
        COLORS["green"], COLORS["green"],
        ["🍋", "🍙"], "コンビニ（小）"
    )
    save(img, "store", "medium_store.png")

    img = make_store(
        "full_store", COLORS["bg_blue"], "#BBDEFB",
        COLORS["blue"], COLORS["blue"],
        ["🍋", "🍙", "🍱"], "コンビニ（大）"
    )
    save(img, "store", "full_store.png")

# ─── 商品アセット ─────────────────────────────────────────────────

def make_product(emoji, label, bg_color, accent, size=(256, 256)):
    img, draw = make_canvas(size, COLORS["white"])
    w, h = size

    # 背景サークル
    draw_circle(draw, (w//2, h//2 - 10), 100, bg_color)

    # 絵文字
    draw_emoji_text(draw, img, emoji, (w//2, h//2 - 10), size=100)

    # ラベル帯
    draw_rounded_rect(draw, [10, h - 60, w - 10, h - 10], 8, accent)
    draw_label(draw, label, (w//2, h - 48), color=COLORS["white"], size=22)

    return img

def gen_products():
    print("\n[PRODUCTS] Generating product assets...")

    products = [
        ("🍋", "レモネード", "#FFF9C4", COLORS["gold"],    "lemonade.png"),
        ("🍙", "おにぎり",  "#F1F8E9", COLORS["green"],   "onigiri.png"),
        ("☕", "コーヒー",  "#EFEBE9", COLORS["brown"],   "coffee.png"),
        ("🍱", "お弁当",    "#FFF3E0", COLORS["orange"],  "bento.png"),
        ("🍦", "アイス",    "#FCE4EC", COLORS["pink"],    "ice_cream.png"),
    ]
    for emoji, label, bg, accent, fname in products:
        img = make_product(emoji, label, bg, accent)
        save(img, "products", fname)

# ─── NPC キャラクター ─────────────────────────────────────────────

def make_npc(emoji, name, role, body_color, hat_color, size=(256, 384)):
    img, draw = make_canvas(size, COLORS["white"])
    w, h = size

    # 背景グラデーション風
    for y in range(h):
        t = y / h
        c = int(240 + (255 - 240) * t)
        draw.line([(0, y), (w, y)], fill=(c, c, c, 255))

    # 影
    draw_circle(draw, (w//2, int(h*0.88)), 55, "#E0E0E0")

    # 体
    draw_rounded_rect(draw, [w//2 - 60, int(h*0.52), w//2 + 60, int(h*0.85)], 20, body_color)

    # 帽子・アクセサリー
    draw_rounded_rect(draw, [w//2 - 35, int(h*0.18), w//2 + 35, int(h*0.28)], 8, hat_color)

    # 顔（絵文字）
    draw_circle(draw, (w//2, int(h*0.36)), 65, COLORS["bg_light"])
    draw_emoji_text(draw, img, emoji, (w//2, int(h*0.36)), size=90)

    # 名前
    draw_rounded_rect(draw, [10, h - 90, w - 10, h - 10], 10, body_color)
    draw_label(draw, name, (w//2, h - 76), color=COLORS["white"], size=20)
    draw_label(draw, role, (w//2, h - 46), color=COLORS["white"], size=16)

    return img

def gen_npcs():
    print("\n[NPCS] Generating NPC assets...")

    npcs = [
        ("👨", "店長タロウ",    "マネージャー", COLORS["blue"],   COLORS["teal"],   "manager_taro.png"),
        ("👩", "店長ミキ",      "マネージャー", COLORS["pink"],   COLORS["purple"], "manager_miki.png"),
        ("🎒", "学生さん",      "お客さん",    COLORS["green"],  COLORS["teal"],   "customer_student.png"),
        ("💼", "サラリーマン",   "お客さん",    COLORS["blue"],   COLORS["dark"],   "customer_worker.png"),
        ("👵", "おばあさん",     "お客さん",    COLORS["purple"], COLORS["pink"],   "customer_grandma.png"),
    ]
    for emoji, name, role, body, hat, fname in npcs:
        img = make_npc(emoji, name, role, body, hat)
        save(img, "npcs", fname)

# ─── バッジ ───────────────────────────────────────────────────────

def make_badge(emoji, title, subtitle, ring_color, center_color, size=(256, 256)):
    img, draw = make_canvas(size, COLORS["white"])
    w, h = size

    # 外リング（グロー効果）
    draw_circle(draw, (w//2, h//2 - 10), 108, ring_color + "40" if len(ring_color) == 7 else ring_color)
    draw_circle(draw, (w//2, h//2 - 10), 108, "#" + "".join(f"{max(0,int(x)-30):02X}" for x in hex_to_rgb(ring_color)))
    draw_circle(draw, (w//2, h//2 - 10), 95, ring_color)
    draw_circle(draw, (w//2, h//2 - 10), 80, center_color)

    # 絵文字
    draw_emoji_text(draw, img, emoji, (w//2, h//2 - 10), size=72)

    # タイトル
    draw_rounded_rect(draw, [10, h - 70, w - 10, h - 10], 8, ring_color)
    draw_label(draw, title, (w//2, h - 58), color=COLORS["white"], size=20)
    draw_label(draw, subtitle, (w//2, h - 30), color=COLORS["white"], size=14)

    return img

def gen_badges():
    print("\n[BADGES] Generating badge assets...")

    badges = [
        ("⭐", "初売り達成！",   "First Sale",     COLORS["gold"],   "#FFF9C4", "badge_first_sale.png"),
        ("💰", "利益マスター",   "Profit Master",  COLORS["green"],  "#E8F5E9", "badge_profit_master.png"),
        ("🔥", "7日連続プレイ",  "Week Streak",    COLORS["orange"], "#FFF3E0", "badge_week_streak.png"),
    ]
    for emoji, title, subtitle, ring, center, fname in badges:
        img = make_badge(emoji, title, subtitle, ring, center)
        save(img, "badges", fname)

# ─── UIアイコン ───────────────────────────────────────────────────

def make_icon(emoji, bg_color, size=(128, 128)):
    img, draw = make_canvas(size, COLORS["white"])
    w, h = size
    draw_rounded_rect(draw, [4, 4, w - 4, h - 4], 24, bg_color)
    draw_emoji_text(draw, img, emoji, (w//2, h//2), size=64)
    return img

def gen_icons():
    print("\n[ICONS] Generating UI icons...")

    icons = [
        ("💰", COLORS["gold"],   "coin_icon.png"),
        ("🏪", COLORS["orange"], "store_icon.png"),
        ("📊", COLORS["blue"],   "chart_icon.png"),
        ("🎯", COLORS["green"],  "target_icon.png"),
        ("🏆", COLORS["gold"],   "trophy_icon.png"),
    ]
    for emoji, bg, fname in icons:
        img = make_icon(emoji, bg)
        save(img, "icons", fname)

# ─── アプリアイコン ───────────────────────────────────────────────

def gen_app_icon():
    print("\n[APP ICON] Generating app icon...")

    size = (1024, 1024)
    img, draw = make_canvas(size, COLORS["white"])
    w, h = size

    # グラデーション背景
    top_rgb = hex_to_rgb(COLORS["orange"])
    bot_rgb = hex_to_rgb("#FF8C42")
    for y in range(h):
        t = y / h
        r = int(top_rgb[0] * (1 - t) + bot_rgb[0] * t)
        g = int(top_rgb[1] * (1 - t) + bot_rgb[1] * t)
        b = int(top_rgb[2] * (1 - t) + bot_rgb[2] * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))

    # 白い円形背景
    draw_circle(draw, (w//2, h//2), 420, COLORS["white"])

    # メイン絵文字
    draw_emoji_text(draw, img, "🏪", (w//2, int(h*0.42)), size=320)

    # サブ絵文字
    draw_emoji_text(draw, img, "💰", (int(w*0.28), int(h*0.7)), size=120)
    draw_emoji_text(draw, img, "📊", (int(w*0.72), int(h*0.7)), size=120)

    save(img, ".", "app_icon.png")

# ─── メイン ───────────────────────────────────────────────────────

def main():
    print("=" * 50)
    print("Business Kids - Asset Generation Start")
    print(f"Output: {BASE}")
    print("=" * 50)

    os.makedirs(BASE, exist_ok=True)
    for folder in ["store", "products", "npcs", "badges", "icons", "events"]:
        os.makedirs(os.path.join(BASE, folder), exist_ok=True)

    gen_stores()
    gen_products()
    gen_npcs()
    gen_badges()
    gen_icons()
    gen_app_icon()

    # 生成ファイル数カウント
    total = 0
    for root, dirs, files in os.walk(BASE):
        total += len([f for f in files if f.endswith(".png")])

    print("\n" + "=" * 50)
    print(f"Done! Generated {total} PNG files in total.")
    print("=" * 50)

if __name__ == "__main__":
    main()
