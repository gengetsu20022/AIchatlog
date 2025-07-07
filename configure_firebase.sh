#!/bin/bash

# FlutterFire設定スクリプト
echo "FlutterFire設定を開始します..."

# Firebase CLIにログイン（必要に応じて）
echo "Firebase CLIのログイン状態を確認中..."
firebase login --no-localhost || echo "Firebase CLIへのログインが必要です"

# FlutterFire設定を実行
echo "FlutterFire設定を実行中..."
flutterfire configure --project=aichatlog-5ade1

echo "FlutterFire設定が完了しました！" 