#!/bin/sh
# gh-merge-guard/merge-guard.sh — PreToolUse(Bash) guard.
#
# Blocks an actual `gh pr merge ... --admin` invocation. Admin bypass merges
# past branch protection and required reviews; in the retro it was used to
# self-merge an agent's own PR. A normal authorized merge is fine — only the
# --admin bypass is blocked, so branch protections still decide.
#
# SCOPE / THREAT MODEL. This is a best-effort speed-bump against a cooperative
# agent carelessly running an admin-bypass merge (the retro incident was a plain
# `gh pr merge N --admin`). It is NOT an adversarial security boundary: a shell
# command string cannot be fully analysed with text rules, so a determined
# obfuscation (variable indirection like `X=--admin; gh pr merge $X`, splitting
# the literal word `merge`, etc.) can still get through. The REAL enforcement is
# server-side GitHub branch protection with required reviews — enable that.
#
# What this DOES reliably do: block direct and chained bypass merges, catch
# simple quote/backslash obfuscation of `--admin` (`--ad""min`, `--ad\min`,
# `--ad'min'`), and NOT false-block a `gh pr create` / `git commit` whose body
# or message merely *documents* the guard (that false-positive fired on PR #40).
#
# Deciding shell dataflow with a regex is a losing game, so this is
# BLOCK-BY-DEFAULT: blank only regions we can PROVE are inert, then match;
# anything else stays visible and blocks. Provably inert:
#   * a documentation-flag value (--body/-b/--title/-t/-m/--message/...) that is
#     a PLAIN quoted string — no command substitution ($( or backtick);
#   * a heredoc body whose sink is cat/gh/git at top level and that is NOT routed
#     onward into execution (no pipe/;/&/backtick/redirect after the tag, no
#     process substitution or interpreter around the sink).
# Over-blocks exotic constructs (safe direction); does not fail open on the
# realistic bypass forms. If perl is unavailable we fall back to a raw
# (unblanked) match, which only over-blocks.
#
# Reads the hook JSON from stdin, extracts .tool_input.command via jq.
# Exits 0 (allow) or 2 (deny, message on stderr).
input=$(cat)

# Fast path: a command that never mentions "merge" can't be a bypass merge.
case "$input" in
  *merge*) ;;
  *) exit 0 ;;
esac

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || exit 0

if command -v perl >/dev/null 2>&1; then
  scan=$(printf '%s' "$cmd" | perl -0777 -pe '
    # 0. Join backslash-newline line continuations so routing on the next
    #    physical line (e.g. `cat <<EOF \` <newline> `| sh`) is seen inline.
    s/\\\n//g;

    # 1. Heredoc body -> blank ONLY when provably inert: sink is cat/gh/git at a
    #    top-level command position ($(, start, ; & | backtick, newline — NOT a
    #    bare "(" so "<(cat" / subshells stay visible), nothing between sink and
    #    "<<" that redirects/routes, no interpreter/process-subst in the prefix,
    #    and nothing after the tag on the opener line that pipes/redirects the
    #    body onward. Otherwise keep the body visible.
    s{
      (^|[\n;&|`]|\$\()([^\n]*?)<<[-~]?[ \t]*(["\x27]?)([A-Za-z_]\w*)\3
      ([^\n]*)\n(.*?)\n[ \t]*\4[ \t]*(?=\n|$)
    }{
      my ($b,$pre,$tag,$rest,$body)=($1,$2,$4,$5,$6);
      my $inert =
        $pre  =~ m{(?:^|[;&|`]|\$\()[ \t]*(?:cat|gh|git)\b[^;&|`<>]*$}
        && $pre  !~ m{(?:^|[;&|`])[ \t]*(?:eval|exec|sh|bash|zsh|ksh|dash|source|xargs|\.)\b}
        && $pre  !~ m{[<>]\(}
        && $rest !~ m{[|&;`<>]};
      $inert ? "$b$pre$rest" : "$b$pre<<$tag$rest\n$body\n$tag";
    }gemsx;

    # 2. Documentation-flag value -> blank ONLY plain quoted text; keep any value
    #    containing a command substitution ($( or backtick) visible. The short
    #    forms allow a combined single-dash cluster ending in the value flag, so
    #    `git commit -am/-asm "msg"` is handled like `-m "msg"`.
    s{
      (^|[ \t;&|`(])
      ((?:--body|--title|--message|--notes|--subject|--body-text|-[A-Za-z]*[btm])(?:=|[ \t]+))
      ("(?:\\.|[^"\\])*"|\x27[^\x27]*\x27)
    }{
      my ($bnd,$flag,$val)=($1,$2,$3);
      $val =~ /[\$`]/ ? "$bnd$flag$val" : "$bnd$flag ";
    }gex;
  ') || scan=$cmd
else
  scan=$cmd
fi

# Normalize away quote/backslash obfuscation for the token check. `scan` has had
# its inert regions blanked already, so stripping quotes here cannot resurrect
# documentation tokens — it only collapses forms like `--ad""min` -> `--admin`.
norm=$(printf '%s' "$scan" | tr -d '\047\042\134')   # remove ' " \

case "$norm" in
  *"gh pr merge"*)
    case "$norm" in
      *"--admin"*)
        printf '%s\n' "Blocked: 'gh pr merge --admin' bypasses branch protection (used in the retro to self-merge an own PR). Get explicit user authorization, then merge WITHOUT --admin so required reviews and checks still apply." >&2
        exit 2
        ;;
    esac
    ;;
esac
exit 0
