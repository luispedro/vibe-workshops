"""Cumulative input tokens over a chat: what you typed, what was sent, and
what you pay for once the provider caches the prefix.

Toy numbers, chosen to be round rather than measured: each turn you type 20
tokens and the model answers with 200. Every turn re-sends the whole
conversation; with caching, the already-seen prefix is billed at 10% of the
normal input price (roughly what Anthropic charges for a cache read).

    python token-growth.py OUTPUT.{svg,pdf,png}
"""
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

TURNS = 20
TYPED = 20          # tokens you type per turn
REPLY = 200         # tokens the model answers with per turn
CACHE_READ = 0.10   # cached prefix, as a fraction of full input price

# Deck colours (common/style/slides.css): grey for you, Claude orange for the
# model, and one blue for the cached line.
INK, MUTED = "#263238", "#607d8b"
YOU, SENT, CACHED = "#37474f", "#d97757", "#2f6fb0"

turns = list(range(1, TURNS + 1))
typed, sent, cached = [], [], []
t = s = c = 0
for n in turns:
    prefix = (TYPED + REPLY) * (n - 1)
    t += TYPED
    s += prefix + TYPED
    c += CACHE_READ * prefix + TYPED
    typed.append(t / 1000)
    sent.append(s / 1000)
    cached.append(c / 1000)

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "font.size": 14,
    "text.color": INK,
    "axes.labelcolor": MUTED,
    "xtick.color": MUTED,
    "ytick.color": MUTED,
    "svg.fonttype": "none",
})

fig, ax = plt.subplots(figsize=(9, 4.6))
for ys, colour, label in [
    (sent, SENT, "sent to the model"),
    (cached, CACHED, "paid for, with caching"),
    (typed, YOU, "what you typed"),
]:
    ax.plot(turns, ys, color=colour, linewidth=2.5, solid_capstyle="round")
    ax.annotate(label, (turns[-1], ys[-1]), xytext=(8, 0),
                textcoords="offset points", va="center", color=INK)

ax.set_xlabel("turn")
ax.set_ylabel("input tokens, cumulative (thousands)")
ax.set_xlim(1, TURNS)
ax.set_ylim(0, None)
ax.set_xticks([1, 5, 10, 15, 20])
ax.grid(axis="y", color="#eceff1", linewidth=1)
ax.set_axisbelow(True)
for side in ("top", "right"):
    ax.spines[side].set_visible(False)
for side in ("left", "bottom"):
    ax.spines[side].set_color("#b0bec5")
ax.tick_params(length=0)

fig.savefig(sys.argv[1], bbox_inches="tight", transparent=True)
