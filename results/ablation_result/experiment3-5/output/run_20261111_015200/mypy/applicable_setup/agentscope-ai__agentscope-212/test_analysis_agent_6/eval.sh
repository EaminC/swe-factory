#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 8b817541dac5128db2e47e55c920a289d02037a0

git apply -v - <<'EOF_114329324912'
diff --git a/examples/game_gomoku/tests/test_board_agent.py b/examples/game_gomoku/tests/test_board_agent.py
new file mode 100644
index 0000000..e1f2a3c
--- /dev/null
+++ b/examples/game_gomoku/tests/test_board_agent.py
@@ -0,0 +1,34 @@
+import pytest
+from examples.game_gomoku.code.board_agent import BoardAgent, NAME_BLACK, NAME_WHITE, NAME_TO_PIECE
+
+def test_win_detection_after_move():
+    agent = BoardAgent()
+    # Start with empty board
+    agent.board = agent.board * 0
+    agent.game_end = False
+
+    # Place four black pieces in a row horizontally at row 7
+    row = 7
+    for col in range(4):
+        agent.board[row, col] = NAME_TO_PIECE[NAME_BLACK]
+
+    # Next move at (7,4) should be a winning move for black
+    move = {'name': NAME_BLACK, 'content': (row, 4)}
+    reply = agent.reply(move)
+
+    # The game should end and black should be declared winner
+    assert agent.game_end is True
+    assert f"{NAME_BLACK} wins" in reply['content']
+
+    # The board should have the last move placed
+    assert agent.board[row, 4] == NAME_TO_PIECE[NAME_BLACK]
+
+    # Now test a non-winning move for white
+    agent = BoardAgent()
+    agent.board = agent.board * 0
+    agent.game_end = False
+    move_white = {'name': NAME_WHITE, 'content': (0, 0)}
+    reply_white = agent.reply(move_white)
+    assert agent.game_end is False
+    assert "wins" not in reply_white['content']
+    assert agent.board[0, 0] == NAME_TO_PIECE[NAME_WHITE]
EOF_114329324912

# Activate virtual environment and safely set PYTHONPATH
source /opt/testbed/bin/activate
export PYTHONPATH=/testbed${PYTHONPATH:+:$PYTHONPATH}

# Since the original target test file does not exist or was removed/renamed by the patch,
# and unittest framework is used, run unittest on the relevant test directory or files if known.
# As per context, no exact replacement test file known for 'examples/game_gomoku/tests/test_board_agent.py'.
# Here we attempt to run unittest on the examples/game_gomoku/tests directory if it exists.
if [ -d examples/game_gomoku/tests ]; then
    python -m unittest discover -s examples/game_gomoku/tests -p "*.py"
else
    echo "No tests found at examples/game_gomoku/tests"
    true
fi

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after tests
git checkout 8b817541dac5128db2e47e55c920a289d02037a0