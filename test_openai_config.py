#!/usr/bin/env python3
"""
快速测试自定义 OPENAI_KEY 和 OPENAI_API_BASE_URL 是否生效。
在项目根目录执行: python test_openai_config.py
"""
import os
import sys

def main():
    key = os.getenv("OPENAI_KEY")
    base_url = os.getenv("OPENAI_API_BASE_URL")

    print("=== 环境变量检查 ===")
    print(f"OPENAI_KEY: {'已设置 (' + key[:8] + '...)' if key else '未设置'}")
    print(f"OPENAI_API_BASE_URL: {base_url or '(未设置，将使用官方默认)'}")

    if not key:
        print("\n请设置 OPENAI_KEY，例如: export OPENAI_KEY=sk-xxx")
        sys.exit(1)

    print("\n=== 初始化 OpenAI 客户端（与 gpt.py 一致）===")
    from openai import OpenAI
    client = OpenAI(
        api_key=key,
        base_url=base_url or None,
        timeout=30,
    )
    print("客户端创建成功。")

    # 使用与网关一致的模型 ID，如 tensorblock/gpt-4.1-mini
    model = os.getenv("OPENAI_TEST_MODEL", "tensorblock/gpt-4.1-mini")
    print(f"\n=== 发送一次简单请求（model: {model}）===")
    try:
        r = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": "Say hello in one word."}],
            max_tokens=10,
        )
        content = r.choices[0].message.content
        print(f"响应: {content}")
        print("请求成功，你的 base URL 和 API key 配置正常。")
    except Exception as e:
        print(f"请求失败: {e}")
        sys.exit(1)
#打印所有可用模型
    print("=== 所有可用模型 ===")
    models = client.models.list()
    for model in models:
        print(model.id)

if __name__ == "__main__":
    main()
