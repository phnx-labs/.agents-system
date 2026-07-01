#!/bin/sh
# gh-merge-guard/merge-guard.sh — PreToolUse(Bash) guard.
#
# Blocks an actual `gh pr merge ... --admin` invocation. Admin bypass merges
# past branch protection and required reviews; in the retro it was used to
# self-merge an agent's own PR. A normal authorized merge is fine — only the
# --admin bypass is blocked, so branch protections still decide.
#
# The hard part is telling a real INVOCATION from body/message TEXT that merely
# mentions the tokens (a `gh pr create` / `git commit` whose --body or -m
# documents the guard, as this repo's own rules do — that false-positive fired
# on a `gh pr create` during PR #40). Deciding shell dataflow with a regex is a
# losing game, so this is BLOCK-BY-DEFAULT: we blank only regions that are
# PROVABLY inert, then match; anything we can't prove inert stays visible and
# blocks. Two inert regions:
#   * a documentation-flag value (--body/-b/--title/-t/-m/--message/...) that is
#     a PLAIN quoted string — no command substitution ($( or backtick). Always
#     inert: a literal string arg never executes. A value with $()/backtick is
#     KEPT visible (it can run a merge, e.g. -m "$(gh pr merge --admin)").
#   * a heredoc body whose sink is cat/gh/git at top level AND that is NOT routed
#     onward into execution — no pipe/;/&/backtick/redirect after the tag, no
#     process substitution or interpreter (sh/bash/eval/source/. /xargs) around
#     the sink. So `cat <<EOF|sh`, `sh <(cat <<EOF)`, `eval $(cat <<EOF)`,
#     `. /dev/stdin <<EOF`, `cat <<EOF >x.sh` all KEEP the body -> block.
# This over-blocks exotic constructs (safe direction); it never fails open on a
# genuine bypass. If perl is unavailable we fall back to the raw substring match
# (also block-biased, never fails open).
#
# Reads the hook JSON from stdin, extracts .tool_input.command via jq.
# Exits 0 (allow) or 2 (deny, message on stderr).
input=$(cat)

# Fast path: text that never even mentions a pr merge can't be a bypass merge.
case "$input" in
  *"gh pr merge"*) ;;
  *) exit 0 ;;
esac

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || exit 0

if command -v perl >/dev/null 2>&1; then
  scan=$(printf '%s' "$cmd" | perl -0777 -pe '
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
    #    containing a command substitution ($( or backtick) visible.
    s{
      ((?:--body|--title|--message|--notes|--subject|--body-text|-b|-t|-m)(?:=|[ \t]+))
      ("(?:\\.|[^"\\])*"|\x27[^\x27]*\x27)
    }{
      my ($flag,$val)=($1,$2);
      $val =~ /[\$`]/ ? "$flag$val" : "$flag ";
    }gex;
  ') || scan=$cmd
else
  scan=$cmd
fi

case "$scan" in
  *"gh pr merge"*)
    case "$scan" in
      *"--admin"*)
        printf '%s\n' "Blocked: 'gh pr merge --admin' bypasses branch protection (used in the retro to self-merge an own PR). Get explicit user authorization, then merge WITHOUT --admin so required reviews and checks still apply." >&2
        exit 2
        ;;
    esac
    ;;
esac
exit 0
